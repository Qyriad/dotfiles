(function () {
  if (chrome === null || chrome === undefined) {
    chrome = {};
  }
  if (chrome.storage) {
    return;
  }

  function StorageChange(oldValue, newValue) {
    this.oldValue = oldValue;
    this.newValue = newValue;
  }


  function StorageArea(storage) {
    this.storage = storage;
  }


  function applyFunctorPerItem(items, functor) {
    if (typeof items === 'string') {
      functor(items);
    }
    if (typeof items === 'object') {
      if (Object.prototype.toString.call(keys) === '[object Array]') {
        items.forEach(function (val) {
          functor(items[val]);
        })
      } else {
        for (var key in items) {
          if (items.hasOwnProperty(key)) {
            functor(key, items[key]);
          }
        }
      }
    }

  }

  StorageArea.prototype.get = function (items, callback) {
    var returnItems = {};
    var storage = this.storage;
    if (items === null) {
      for (var i = 0; i < storage.length; i++) {
        var key2 = storage.key(i);
        returnItems[key2] = storage.getItem(key2);
      }
    } else {
      applyFunctorPerItem(items, function (key) {
        var storedItem = storage.getItem(key);
        if (arguments.length === 2 && storedItem === null) {
          storedItem = arguments[1];
        }
        returnItems[key] = storedItem;
      });
    }

    callback && callback(returnItems);
  };

  StorageArea.prototype.set = function (items, callback) {
    var storage = this.storage;
    applyFunctorPerItem(items, function (key, value) {
      storage.setItem(key, value);
    });
    callback && callback();
  };

  StorageArea.prototype.remove = function (items, callback) {
    var storage = this.storage;
    applyFunctorPerItem(items, function (key) {
      storage.removeItem(key);
    });
    callback && callback();
  };

  StorageArea.prototype.clear = function (callback) {
    this.storage.clear();
    callback && callback();
  };

  function SyncStorageMock() {
    var values = {};
    this.setItem = function (item, value) {
      values[item] = value;
    };
    this.getItem = function (item) {
      return values[item];
    };
    this.removeItem = function (item) {
      delete values[item];
    };
    this.clear = function () {
      values = {};
    };
    this.key = function (key) {
      var keys = [];
      for (var i in values) {
        keys.push(i);
      }
      return keys[key];
    };
    this.__defineGetter__("length", function () {
      var keys = [];
      for (var i in values) {
        keys.push(i);
      }
      return keys.length;
    });

  }

  chrome.storage = {
    sync: new StorageArea(new SyncStorageMock()),
    local: new StorageArea(localStorage)
  };


})();
