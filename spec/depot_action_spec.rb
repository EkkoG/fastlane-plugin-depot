describe Fastlane::Actions::DepotAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The depot plugin is working!")

      Fastlane::Actions::DepotAction.run(nil)
    end
  end
end
