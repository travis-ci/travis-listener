require 'spec_helper'
require 'travis/listener/helper/retrying'

describe Travis::Listener::Retrying do
  it 'retrying' do
    count = 0
    described_class.retrying(max: 5, wait: 0.001) do
      count += 1
      raise Redis::BaseError
    end rescue nil
    expect(count).to eq 6
  end
end
