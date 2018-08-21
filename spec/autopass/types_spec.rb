require 'autopass/types'

describe Types do
  describe Types::String do
    it 'coerces to string' do
      expect(Types::String[1]).to eq('1')
    end

    it 'expands environment variables' do
      expect(Types::String['%<HOME>s']).to eq(ENV['HOME'])
    end
  end

  describe Types::Pathname do
    it 'returns a pathname' do
      expect(Types::Pathname['/foo/bar']).to eq(Pathname.new('/foo/bar'))
    end

    it 'expands environment variables' do
      expect(Types::Pathname['%<HOME>s']).to eq(Pathname.new(ENV['HOME']))
    end

    it 'expands paths' do
      expect(Types::Pathname['/foo/../bar']).to eq(Pathname.new('/bar'))
    end
  end

  describe Types::SpaceSeparatedArray do
    it 'returns an array' do
      expect(Types::SpaceSeparatedArray['foo']).to be_an(Array)
    end

    it 'expands environment variables' do
      expect(Types::SpaceSeparatedArray['%<HOME>s']).to eq([ENV['HOME']])
    end

    it 'splits space separated values' do
      expect(Types::SpaceSeparatedArray['foo bar baz']).to eq(%w[foo bar baz])
    end
  end
end
