(function() {

  var extend = Parser.extend;

  Parser.Address = {};

  Parser.Address.IPv4 = function() {
    this.init();
  };

  extend(Parser.Address.IPv4.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;

      self.parser = parser.and([
        parser.repeat(
          parser.and([
            parser.byte(),
            parser.character('.')]),
          3),
        parser.byte()]);
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());

      App.Log('Parser.Address.IPv4.parse');

      if (inStream.remaining() === 0) {
        return false;
      }

      if (self.parser.parse(parseState)) {
        inStream.setMark(mark);
        parseState.address = inStream.markedCharacterRange();
        return true;
      } else {
        inStream.setPosition(mark);
        return false;
      }
    }
  });

  Parser.Address.ipv4 = function() {
    return new Parser.Address.IPv4();
  };

  Parser.Address.IPv6 = function() {
    this.init();
  };

  extend(Parser.Address.IPv6.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;

      self.prefixParser = parser.character('[');
      self.addressParser = parser.and([
        parser.repeat(
          parser.and([
            parser.repeat(parser.hexadecimal(), 1, 4),
            parser.character(':')]),
          7),
        parser.repeat(parser.hexadecimal(), 1, 4)]);
      self.postfixParser = parser.character(']');
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());
      var addressMark = mark;
      var address = '';

      App.Log('Parser.Address.IPv6');

      if (inStream.remaining() === 0) {
        return false;
      }

      if (!self.prefixParser.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }

      addressMark = inStream.setMark(inStream.position());

      if (self.addressParser.parse(parseState)) {
        inStream.setMark(addressMark);
        address = inStream.markedCharacterRange();

        if (self.postfixParser.parse(parseState)) {
          parseState.address = address;
          return true;
        } else {
          inStream.setPosition(mark);
          return false;
        }
      } else {
        inStream.setPosition(mark);
        return false;
      }
    }
  });

  Parser.Address.ipv6 = function() {
    return new Parser.Address.IPv6();
  };

  Parser.Address.Port = function() {
    this.init();
  };

  extend(Parser.Address.Port.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;

      self.parser = parser.and([
        parser.repeat(parser.character(':'), 1, 2),
        parser.decimal(1, 65535)]);
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());

      App.Log('Parser.Address.Port.parse');

      if (inStream.remaining() === 0) {
        return false;
      }

      if (self.parser.parse(parseState)) {
        parseState.port = parseState.value;
        return true;
      } else {
        inStream.setPosition(mark);
        return false;
      }
    }
  });

  Parser.Address.port = function() {
    return new Parser.Address.Port();
  };

  Parser.Address.Display = function() {
    this.init();
  };

  extend(Parser.Address.Display.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;

      self.parser = parser.and([
        parser.character(':'),
        parser.decimal(0, 99)]);
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());

      App.Log('Parser.Address.Display.parse');

      if (inStream.remaining() === 0) {
        return false;
      }

      if (self.parser.parse(parseState)) {
        parseState.port = 5900 + parseState.value;
        return true;
      } else {
        inStream.setPosition(mark);
        return false;
      }
    }
  });

  Parser.Address.display = function() {
    return new Parser.Address.Display();
  };

  Parser.Address.HostName = function() {
    this.init();
  };

  extend(Parser.Address.HostName.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;

      // See section 3.5 of RFC 1034 and section 2.1 of RFC 1123
      var letterDigit = parser.alphaNumermic();

      var hypen = parser.character('-');

      var letterDigitHypenString = parser.repeatAny(
        parser.or([
          parser.and([
            parser.lookAhead(
              parser.and([
                parser.repeatAtLeastOnce(hypen),
                letterDigit])),
            parser.repeatAtLeastOnce(hypen)]),
          letterDigit]));

      var label = parser.and([
        letterDigit,
        letterDigitHypenString]);

      var subDomain = parser.and([
        parser.repeatAny(
          parser.and([
            label,
            parser.character('.')])),
        label]);

      var domain = parser.or([
        subDomain,
        parser.character(' ')]);

      self.parser = domain;
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());

      App.Log('Parser.Address.HostName.parse');

      if (inStream.remaining() === 0) {
        return false;
      }

      if (self.parser.parse(parseState)) {
        inStream.setMark(mark);
        parseState.address = inStream.markedCharacterRange();
        return true;
      } else {
        inStream.setPosition(mark);
        return false;
      }
    }
  });

  Parser.Address.hostName = function() {
    return new Parser.Address.HostName();
  };

  Parser.Address.parse = function(possibleAddress) {
    var inStream = new Parser.InStream(possibleAddress);
    var didParse = false;
    var parseState = {
      inStream: inStream
    };

    var parser = Parser;
    var address = Parser.Address;

    var displayOrPort = parser.optional(
      parser.or([
        parser.and([
          parser.lookAhead(
            parser.and([
              address.display(),
              parser.not(parser.digit())])),
          address.display()]),
        address.port()]));

    var addressParser = parser.or([
      parser.and([
        address.ipv4(),
        displayOrPort]),
      parser.and([
        address.ipv6(),
        displayOrPort]),
      parser.and([
        address.hostName(),
        displayOrPort])]);

    didParse = addressParser.parse(parseState);

    parseState.didParse = didParse;

    return parseState;
  };

})();
