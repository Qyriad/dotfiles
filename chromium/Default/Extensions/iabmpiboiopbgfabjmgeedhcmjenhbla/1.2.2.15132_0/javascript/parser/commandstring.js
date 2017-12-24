(function() {

  var extend = Parser.extend;

  Parser.CommandString = function() {
    this.init();
  };

  extend(Parser.CommandString.prototype, {
    init: function() {
      var self = this;
      var parser = Parser;
      var commandString = parser.CommandString;

      self.parser = parser.and([
        parser.literalString('vnccmd:'),
        commandString.field({name: 'v', value: '1'}),
        parser.repeatAny(
          parser.and([
            parser.character(';'),
            commandString.field()]))]);

      self.typeVerifier = parser.repeatAtLeastOnce(
        parser.or([
          parser.upperCase(),
          parser.digit(),
          parser.character('_')]));
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());
      var fields;
      var isTypeVerified = false;

      App.Log('Parser.CommandString.parse');

      if (inStream.remaining() === 0) {
        inStream.setPosition(mark);
        return false;
      }

      if (!self.parser.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }

      fields = parseState.fields;
      if (!fields.some(function(field) {
        if (field.name !== 't') {
          return false;
        }
        return self.typeVerifier.parse({
          inStream: new Parser.InStream(field.value)
        });
      })) {
        inStream.setPosition(mark);
        return false;
      }

      return true;
    }
  });

  Parser.CommandString.Field = function(options) {
    this.init(options);
  };

  extend(Parser.CommandString.Field.prototype, {
    init: function(options) {
      var self = this;
      var parser = Parser;
      var commandString = parser.CommandString;
      var field = commandString.Field;

      self.name = field.token("$-_.+!*'()");
      self.delimiter = parser.character('=');
      self.value = field.token("$-_.+!*'()=");
      if (options && ("name" in options)) {
        self.name = parser.literalString(options.name);
      }
      if (options && ("value" in options)) {
        self.value = parser.literalString(options.value);
      }
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());
      var tokenMark = mark;
      var name;
      var value;
      App.Log('Parser.CommandString.Field.parse');
      if (inStream.remaining() === 0) {
        return false;
      }
      if (!self.name.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }
      inStream.setMark(tokenMark);
      name = inStream.markedCharacterRange();
      if (!self.delimiter.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }
      tokenMark = inStream.setMark(inStream.position());
      if (!self.value.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }
      inStream.setMark(tokenMark);
      value = inStream.markedCharacterRange();
      if (!("fields" in parseState)) {
        parseState.fields = [];
      }
      if (parseState.fields.some(function(field) {
        return name === field.name;
      })) {
        inStream.setPosition(mark);
        return false;
      }
      parseState.fields.push({
        name: name,
        value: value
      });
      return true;
    }
  });

  Parser.CommandString.Field.Token = function(
    permissableNonAlphaNumericCharacters) {
    this.init(permissableNonAlphaNumericCharacters);
  };

  extend(Parser.CommandString.Field.Token.prototype, {
    init: function(permissableNonAlphaNumericCharacters) {
      var self = this;
      var parser = Parser;
      self.parser = parser.repeatAtLeastOnce(
          parser.or([
            parser.alphaNumermic(),
            parser.character(permissableNonAlphaNumericCharacters)]));
    },

    parse: function(parseState) {
      var self = this;
      var inStream = parseState.inStream;
      var mark = inStream.setMark(inStream.position());
      App.Log('Parser.CommandString.Field.Token.parse');
      if (inStream.remaining() === 0) {
        return false;
      }
      if (!self.parser.parse(parseState)) {
        inStream.setPosition(mark);
        return false;
      }
      inStream.setMark(mark);
      parseState.token = inStream.markedCharacterRange();
      return true;
    }
  });

  Parser.CommandString.Field.token = function(
    permissableNonAlphaNumericCharacters) {
      return new Parser.CommandString.Field.Token(
        permissableNonAlphaNumericCharacters);
  };

  Parser.CommandString.field = function(options) {
    return new Parser.CommandString.Field(options);
  };

  Parser.CommandString.parse = function(possibleCommandString) {
    var inStream = new Parser.InStream(possibleCommandString);
    var parseState = {
      inStream: inStream
    };
    var parser = new Parser.CommandString();
    var didParse = parser.parse(parseState);
    parseState.didParse = didParse;
    return parseState;
  };

}());
