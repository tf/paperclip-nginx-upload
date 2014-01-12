require 'spec_helper'

describe Paperclip::Nginx::Upload::IOAdapter do
  context 'for tmp file in whitelist' do
    let :tempfile do
      fixture_file('5k.png').binmode
    end

    subject do
      nginx_upload_hash = {
        :original_name => '5k.png',
        :tmp_path => tempfile.path,
        :content_type => "image/x-png-by-browser\r"
      }

      options = {
        :tmp_path_whitelist => [File.join(PROJECT_ROOT, 'spec', 'tmp', '**')]
      }

      Paperclip::Nginx::Upload::IOAdapter.new(nginx_upload_hash, options)
    end

    it 'gets the right filename' do
      expect(subject.original_filename).to eq('5k.png')
    end

    it 'gets content type' do
      expect(subject.content_type).to eq('image/x-png-by-browser')
    end

    it 'gets the file\'s size' do
      expect(subject.size).to eq(4456)
    end

    it 'returns false for a call to nil?' do
      expect(subject.nil?).to be(false)
    end

    it 'generates a MD5 hash of the contents' do
      hash = Digest::MD5.file(tempfile.path).to_s
      expect(subject.fingerprint).to eq(hash)
    end

    it 'reads the contents of the file' do
      content = tempfile.read
      expect(content.length).to be > 0
      expect(subject.read).to eq(content)
    end
  end

  context 'for tmp file not in whitelist' do
    let :tempfile do
      fixture_file('5k.png').binmode
    end

    it 'raises an exception' do
      nginx_upload_hash = {
        :original_name => '5k.png',
        :tmp_path => tempfile.path,
        :content_type => "image/x-png-by-browser\r"
      }

      expect {
        Paperclip::Nginx::Upload::IOAdapter.new(nginx_upload_hash, :tmp_path_whitelist => [])
      }.to raise_error(Paperclip::Nginx::Upload::TmpPathNotInWhitelistError)
    end
  end
end
