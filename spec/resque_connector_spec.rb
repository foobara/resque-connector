RSpec.describe Foobara::CommandConnectors::ResqueConnector do
  after do
    Foobara::ResqueConnector.reset_all
  end

  let(:command_connector) { described_class.new }

  let(:command_class) do
    stub_module "SomeOrg" do
      foobara_organization!
    end
    stub_module "SomeOrg::SomeDomain" do
      foobara_domain!
    end
    stub_class "SomeOrg::SomeDomain::DoSomething", Foobara::Command do
      inputs do
        foo :integer
        bar :string
      end

      def execute
        "success! #{foo} #{bar}"
      end
    end
  end

  it "has a version number" do
    expect(Foobara::ResqueConnector::VERSION).to_not be_nil
  end

  describe ".connect" do
    before do
      command_connector.connect(command_class)
    end

    it "gives a working Enqueue*Command RunCommandAsync subclass" do
      command = SomeOrg::SomeDomain::DoSomethingAsync.new(foo: 1, bar: "bar")

      expect {
        command.run!
      }.to change { Resque.size(:general) }.from(0).to(1)

      job = Resque.peek(:general, 0, 1)

      expect(job["class"]).to eq("Foobara::CommandConnectors::ResqueConnector::CommandJob")

      args = job["args"].first
      command_name = args["command_name"]
      inputs = args["inputs"]

      expect(command_name).to eq("SomeOrg::SomeDomain::DoSomething")
      expect(inputs).to eq("foo" => 1, "bar" => "bar")

      worker = Resque::Worker.new(:general)

      expect(worker.work_one_job).to be(true)
      expect(Resque::Failure.count).to be(0)
      expect(Resque.size(:general)).to be(0)
    end
  end
end
