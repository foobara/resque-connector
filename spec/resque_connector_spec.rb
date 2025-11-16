RSpec.describe Foobara::CommandConnectors::ResqueConnector do
  after do
    Foobara.reset_alls
  end

  let(:command) { SomeOrg::SomeDomain::DoSomethingAsync.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors_hash) { outcome.errors_hash }
  let(:inputs) do
    { foo: 1, bar: "bar" }
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

  describe ".connect" do
    before do
      command_connector.connect(command_class)
    end

    it "gives a working Enqueue*Command RunCommandAsync subclass" do
      expect {
        expect(outcome).to be_success
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

    context "when passing a bad input" do
      let(:inputs) do
        { baz: "100" }
      end

      it "gives an expected validation error" do
        expect(outcome).to_not be_success
        expect(errors_hash.size).to be 1
        expect(errors_hash["data.unexpected_attributes"][:context][:unexpected_attributes]).to eq([:baz])
      end
    end
  end
end
