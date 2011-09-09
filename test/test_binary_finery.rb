require 'helper'
require 'stringio'

def StringIO.of_size(size, &block)
  if (not size.kind_of?(Integer)) || (size < 0)
    raise ArgumentError, 'positive integer required'
  end
  new(0.chr * size, &block)
end

class TestBinaryFinery < BinaryFinery::TestCase
  def setup
    @mockup = StringIO.new.extend(BinaryFinery)
  end

  def host_endianness
    first_byte = [1].pack('i')[0]
    [1,"\x01"].include?(first_byte) ? :little : :big
  end

  def test_detect_platform_endianness
    assert_equal BinaryFinery::NATIVE_BYTE_ORDER, host_endianness
  end

  def test_detect_platform_integer_size
    assert_equal BinaryFinery::INTEGER_SIZE_IN_BYTES, 1.size
  end

  def test_buffer_includes_binary
    assert(@mockup.class.included_modules & [BinaryFinery])
  end

  def test_read_correctly_1_byte
    buf = StringIO.of_size(2).extend(BinaryFinery)
    buf.rewind
    buf.write_uint8(0x55)
    buf.rewind

    assert_equal 0x55, buf.read_uint8
  end

  def test_does_not_care_about_overflow
    overflow = 0xFF + 1
    buf = StringIO.of_size(1).extend(BinaryFinery)
    buf.rewind
    buf.write_uint8(overflow)
    buf.rewind

    assert_equal 0, buf.read_uint8
  end

  def test_read_correctly_2_bytes
    buf = StringIO.of_size(2).extend(BinaryFinery)
    buf.rewind
    buf.write_uint16_little(0x55)
    buf.rewind

    assert_equal 0x55, buf.read_uint16_little
  end

  def test_does_not_care_about_overflow_for_uint32
    overflow = 0xFFFFFFFF + 1
    buf = StringIO.of_size(4).extend(BinaryFinery)
    buf.rewind
    buf.write_uint32(overflow)
    buf.rewind

    assert_equal 0, buf.read_uint32
  end

  def test_read_correctly_4_bytes
    v2 = [0x32, 0x24, 0x00, 0x00]
    v2.reverse! if host_endianness.equal? :little
    packed = v2.pack("C" * v2.size)
    buf = StringIO.new(packed).extend(BinaryFinery)

    buf.size.times do |i|
      assert_equal v2[i], buf.read_uint8
    end
  end

  def test_write_fixed_size_string
    content = 'new blips are arbitrarily created in the electronic transaction system of the Federal Reserve (known as FedWire), no outside detection is possible whatsoever because there is no outside system that verifies (or even can verify) the total quantity of FedWire deposits'
    buf = StringIO.of_size(content.size).extend(BinaryFinery)
    buf.rewind
    buf.write_fixed_size_string(content)
    buf.rewind

    assert_equal content, buf.gets.chomp
  end

  def test_find_bytesize_for_int16_little
    buf = StringIO.new('').extend(BinaryFinery)
    assert_equal 2, buf.size_of('read_int16_little')
  end

  def test_write_uint64_native
    n = 0xB70A4625F1A224CF # Big endian
    bytes = [0xB7, 0x0A, 0x46, 0x25, 0xF1, 0xA2, 0x24, 0xCF]
    bytes.reverse! if BinaryFinery::NATIVE_BYTE_ORDER.equal? :little
    
    buf = StringIO.of_size(8).extend(BinaryFinery)

    buf.rewind
    buf.write_uint64(n)
    buf.rewind

    bytes.each_with_index do |byte, i|
      buf.pos = i
      assert_equal byte, buf.read_uint8
    end
    buf.rewind
    expected = bytes.pack("C"*bytes.size)
    assert_equal n, buf.read_uint64
  end

  def test_write_uint64_little
  #    write_uint64_little(1)                 # services
    n = 1
    buf = StringIO.of_size(8).extend(BinaryFinery)
    buf.write_uint64_little(n)
    buf.rewind
  
    assert_equal n, buf.read_uint64_little
  end

  def test_write_uint128_little
   # write_uint128_network(0xFFFF00000000)  # ip_address
    n = 0xFFFF00000000
    buf = StringIO.of_size(16).extend(BinaryFinery)
    buf.write_uint128_little(n)
    buf.rewind

    assert_equal n, buf.read_uint128_little
  end

  def test_write_uint128_big
    n = 0xFFFF00000000
    buf = StringIO.of_size(16).extend(BinaryFinery)
    buf.write_uint128_big(n)
    buf.rewind

    assert_equal n, buf.read_uint128_big
  end

  def test_read_uint128_little
    n = rand(2**128)
    assert_equal 16, n.size
    buf = StringIO.of_size(16).extend(BinaryFinery)
    buf.write_uint128_little(n)
    buf.rewind

    assert_equal n, buf.read_uint128_little
  end

  def test_read_uint256_little
    n = rand(2**256)
    assert_equal 32, n.size
    buf = StringIO.of_size(32).extend(BinaryFinery)
    buf.write_uint256_little(n)
    buf.rewind

    assert_equal n, buf.read_uint256_little
  end

  def test_read_int128_little
    skip
    n = -rand(2**127)
    assert_equal 16, n.size
    buf = StringIO.of_size(16).extend(BinaryFinery)
    buf.write_int128_little(n)
    buf.rewind

    assert_equal n, buf.read_int128_little
  end

  def test_read_int256_little
    skip
    n = -rand(2**255)
    assert_equal 32, n.size
    buf = StringIO.of_size(32) { write_int256_little(n) }
    assert_equal n, buf.read_int256_little
  end
end

# test read
bytes_ary = [1,2,4,8]

bytes_ary.each do |bytes|
  [:int, :uint].each do |type|
    [:native, :little, :big, :network].each do |mapped_endian|
      next if bytes.equal? 1
      TestBinaryFinery.class_eval do
        bits    = bytes * 8
        packing = { :bytes => bytes, :type => type, :endian => mapped_endian }

        # read
        read_method = "read_#{type}#{bits}_#{mapped_endian}"
        define_method "test_#{read_method}" do
          number = random_integer(bits, type)
          packed_number = pack_integer(number, packing)
          buf = StringIO.new(packed_number).extend(BinaryFinery)

          assert number, buf.send(read_method)
        end

        # write
        write_method = "write_#{type}#{bits}_#{mapped_endian}"
        define_method "test_#{write_method}" do
          number = random_integer(bits, type)
          buf = StringIO.of_size(bytes).extend(BinaryFinery)
          buf.send(write_method, number)
          buf.rewind
          
          assert number, buf.send(read_method)
        end

        #size
        define_method "test_#{type}#{bits}_length_is_#{bytes}_bytes" do
          assert bytes, StringIO.new('').extend(BinaryFinery).size_of(read_method)
          assert bytes, StringIO.new('').extend(BinaryFinery).size_of(write_method)
        end
      end
    end
    [nil].each do |no_endian_specified|
      bits = bytes * 8
      packing = { :bytes  => bytes,
                  :type   => type,
                  :endian => no_endian_specified }

      TestBinaryFinery.class_eval do
        read_method = "read_#{type}#{bits}"
        define_method "test_#{read_method}" do
          number = random_integer(bits, type)
          packed = pack_integer(number, packing)
          buf = StringIO.new(packed).extend(BinaryFinery)

          assert number, buf.send(read_method)
        end

        write_method = "write_#{type}#{bits}"
        define_method "test_#{write_method}" do
          number = random_integer(bits, type)
          buf = StringIO.of_size(bytes).extend(BinaryFinery)
          buf.rewind
          buf.send(write_method, number)
          buf.rewind
          
          assert number, buf.send(read_method)
        end
      end
    end
  end
end

