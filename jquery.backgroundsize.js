(function() {
  var Tween, extend, _init, _parse;

  extend = $.extend, Tween = $.Tween;

  _init = function(tween) {
    var elem, end, prop;

    elem = tween.elem, prop = tween.prop, end = tween.end;
    return extend(tween, {
      start: _parse($(elem).css(prop)),
      end: _parse(end),
      set: true
    });
  };

  _parse = function(val) {
    var arr, dim, _i, _len, _ref, _results;

    _ref = (function() {
      var _j, _len, _ref, _results1;

      _ref = val.split(/\s+/);
      _results1 = [];
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        dim = _ref[_j];
        _results1.push(dim.match(/^(\d+)(.*)$/));
      }
      return _results1;
    })();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      arr = _ref[_i];
      _results.push((function(arr) {
        arr[1] = parseFloat(arr[1]);
        return arr;
      })(arr));
    }
    return _results;
  };

  extend(Tween.propHooks, {
    backgroundSize: {
      get: function(tween) {
        return _parse($(tween.elem).css(tween.prop));
      },
      set: function(tween) {
        var axis, elem, end, pos, prop, start, unit, _adjusted, _span;

        if (!tween.set) {
          _init(tween);
        }
        elem = tween.elem, prop = tween.prop, pos = tween.pos, unit = tween.unit, start = tween.start, end = tween.end;
        _span = function(axis) {
          return end[axis][1] - start[axis][1];
        };
        _adjusted = function(axis) {
          return start[axis][1] + pos * _span(axis);
        };
        return $(elem).css(prop, ((function() {
          var _i, _len, _ref, _results;

          _ref = [0, 1];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            axis = _ref[_i];
            _results.push("" + (_adjusted(axis)) + unit);
          }
          return _results;
        })()).join(' '));
      }
    }
  });

}).call(this);
