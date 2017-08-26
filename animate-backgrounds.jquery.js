(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jquery"), require("jquery-color"));
	else if(typeof define === 'function' && define.amd)
		define(["jquery", "jquery-color"], factory);
	else {
		var a = typeof exports === 'object' ? factory(require("jquery"), require("jquery-color")) : factory(root["jQuery"], root["jQuery"]);
		for(var i in a) (typeof exports === 'object' ? exports : root)[i] = a[i];
	}
})(this, function(__WEBPACK_EXTERNAL_MODULE_2__, __WEBPACK_EXTERNAL_MODULE_3__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 1);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (arg) {
  var Color, _css_val, _extract_changes, _looks_like_shorthand, _parse_shorthand, angle_from_direction, angle_or_direction_regex_chunk, color_regex_chunk, error, gradient_handler, hook, index_regex_chunk, length_regex_chunk, normalize_rel_ops, parse_linear_gradient, parse_radial_gradient, pre_stops_css_linear_gradient, pre_stops_css_radial_gradient, regex_chunk_str, register_animation_handler, relative_length_regex_chunk, scaled, unit_regex_chunk, value_regex_chunk;
  hook = arg.hook, Color = arg.Color;
  register_animation_handler = function register_animation_handler(arg1) {
    var css_val_from_initialized_tween, hook_name, init, init_tween_end, parse, parsed_tween, prop_name;
    prop_name = arg1.prop_name, hook_name = arg1.hook_name, parse = arg1.parse, init_tween_end = arg1.init_tween_end, css_val_from_initialized_tween = arg1.css_val_from_initialized_tween;
    parsed_tween = function parsed_tween(tween) {
      return parse(window.getComputedStyle(tween.elem)[prop_name]);
    };
    init = function init(tween) {
      tween.start = parsed_tween(tween);
      tween.end = init_tween_end({
        tween: tween,
        parse: parse
      });
      return tween.set = true;
    };
    return hook({
      prop_name: prop_name,
      hook_name: hook_name,
      parse: parse,
      parsed_tween: parsed_tween,
      init_tween_end: init_tween_end,
      init: init,
      css_val_from_initialized_tween: css_val_from_initialized_tween
    });
  };
  regex_chunk_str = function regex_chunk_str(regex) {
    var all, chunk, ref;
    ref = /^\/(.*)\/[^\/]*$/.exec(regex.toString()), all = ref[0], chunk = ref[1];
    return chunk;
  };
  unit_regex_chunk = regex_chunk_str(/(%|\w+)?/);
  length_regex_chunk = regex_chunk_str(RegExp("(?:([+-]?\\d+(?:\\.\\d*)?)" + unit_regex_chunk + ")"));
  relative_length_regex_chunk = regex_chunk_str(RegExp("(?:([+-]=)?" + length_regex_chunk + ")"));
  index_regex_chunk = regex_chunk_str(/(?:\[(\d+)\])/);
  _extract_changes = function _extract_changes(arg1) {
    var _change, changed, dim_index, end_dim, end_image, image_index, j, k, len, len1, parsed_end, position, start, start_dim, start_image, unit;
    parsed_end = arg1.parsed_end, start = arg1.start;
    if (parsed_end.length !== start.length) {
      error("Animation end value '" + end + "' has " + parsed_end.length + " background images, but start value has " + start.length);
    }
    _change = [];
    for (image_index = j = 0, len = start.length; j < len; image_index = ++j) {
      start_image = start[image_index];
      end_image = parsed_end[image_index];
      changed = null;
      for (dim_index = k = 0, len1 = start_image.length; k < len1; dim_index = ++k) {
        start_dim = start_image[dim_index];
        end_dim = end_image[dim_index];
        if (!(start_dim.position != null && end_dim.position != null)) {
          continue;
        }
        position = start_dim.position, unit = start_dim.unit;
        if (position === end_dim.position) {
          continue;
        }
        (changed != null ? changed : changed = [])[dim_index] = end_dim;
      }
      if (changed) {
        _change[image_index] = changed;
      }
    }
    return _change;
  };
  normalize_rel_ops = function normalize_rel_ops(arg1) {
    var end_image, image_index, parsed, start;
    parsed = arg1.parsed, start = arg1.start;
    return {
      start: start,
      parsed_end: function () {
        var j, len, results;
        results = [];
        for (image_index = j = 0, len = parsed.length; j < len; image_index = ++j) {
          end_image = parsed[image_index];
          results.push(map(end_image, function (val, dim_index) {
            var position, rel_op;
            if (!(val != null ? val.rel_op : void 0)) {
              return val;
            }
            rel_op = val.rel_op, position = val.position;
            val.position = start[image_index][dim_index].position + position * (rel_op === '-=' ? -1 : 1);
            return val;
          }));
        }
        return results;
      }()
    };
  };
  scaled = function scaled(arg1) {
    var end, pos, prop, start, val;
    start = arg1.start, end = arg1.end, pos = arg1.pos, prop = arg1.prop;
    if (prop) {
      if (is_string(prop)) {
        prop = function (prop) {
          return function (val) {
            return val[prop];
          };
        }(prop);
      }
      start = prop(start);
      end = prop(end);
    }
    val = start + pos * (end - start);
    return val;
  };
  _looks_like_shorthand = function _looks_like_shorthand(end) {
    if (RegExp("\\s*" + length_regex_chunk + "(?:\\s+" + length_regex_chunk + ")?\\s*->|" + index_regex_chunk).exec(end)) {
      return true;
    }
  };
  _parse_shorthand = function _parse_shorthand(arg1) {
    var _change, changing_vals, end, start;
    start = arg1.start, end = arg1.end;
    changing_vals = function () {
      var all, index, indexed_parsed_pairs, match, pair, parsed_pairs, position, ref, ref1, ref2, ref3, ref4, ref5, remaining, second_position, second_unit, separator, set_from_match_params, unit;
      parsed_pairs = [];
      indexed_parsed_pairs = {};
      separator = null;
      index = null;
      remaining = end;
      while (remaining) {
        if (match = RegExp("^\\s*" + index_regex_chunk).exec(remaining)) {
          all = match[0], index = match[1];
          remaining = remaining.slice(all.length);
        }
        match = RegExp("^\\s*" + length_regex_chunk + "(?:[^\\n\\S]+" + length_regex_chunk + ")?\\s*->\\s*").exec(remaining);
        if (!match) {
          match = RegExp("^\\s*" + length_regex_chunk + "[^\\n\\S]+" + length_regex_chunk + "\\s*").exec(remaining);
          all = match[0], position = match[1], unit = (ref = match[2]) != null ? ref : 'px', second_position = match[3], second_unit = (ref1 = match[4]) != null ? ref1 : 'px';
          (indexed_parsed_pairs[index] != null ? indexed_parsed_pairs[index] : indexed_parsed_pairs[index] = []).push({
            start: 'any',
            end: {
              position: position,
              unit: unit,
              second_position: second_position,
              second_unit: second_unit
            },
            type: 'full'
          });
          remaining = remaining.slice(all.length);
          continue;
        }
        all = match[0], position = match[1], unit = (ref2 = match[2]) != null ? ref2 : 'px', second_position = match[3], second_unit = (ref3 = match[4]) != null ? ref3 : 'px';
        pair = {};
        set_from_match_params = function set_from_match_params(start_or_end) {
          pair[start_or_end] = {
            unit: unit,
            position: parseFloat(position)
          };
          if (second_position) {
            if (start_or_end === 'start') {
              pair.type = 'full';
            }
            return extend(pair[start_or_end], {
              second_unit: second_unit,
              second_position: parseFloat(second_position)
            });
          }
        };
        set_from_match_params('start');
        remaining = remaining.slice(all.length);
        match = RegExp("^" + length_regex_chunk + "(?:[^\\n\\S]+" + length_regex_chunk + ")?[^\\n\\S]*([,\\n])?\\s*").exec(remaining);
        all = match[0], position = match[1], unit = (ref4 = match[2]) != null ? ref4 : 'px', second_position = match[3], second_unit = (ref5 = match[4]) != null ? ref5 : 'px', separator = match[5];
        set_from_match_params('end');
        (index != null ? indexed_parsed_pairs[index] != null ? indexed_parsed_pairs[index] : indexed_parsed_pairs[index] = [] : parsed_pairs).push(pair);
        remaining = remaining.slice(all.length);
      }
      return extended(indexed_parsed_pairs, {
        all: parsed_pairs
      });
    }();
    _change = [];
    map(start, function (start_image, image_index) {
      var changed, changing_vals_for_image, dim_index, end_change, j, k, l, len, len1, len2, position, ref, ref1, ref2, ref3, ref4, ref5, second_position, second_unit, start_change, type, unit;
      changing_vals_for_image = changing_vals.all.slice(0).concat((ref = changing_vals[image_index]) != null ? ref : []);
      for (j = 0, len = changing_vals_for_image.length; j < len; j++) {
        ref1 = changing_vals_for_image[j], start_change = ref1.start, end_change = ref1.end, type = ref1.type;
        if (!(type === 'full')) {
          continue;
        }
        (ref2 = start_image[0], position = ref2.position, unit = ref2.unit), (ref3 = start_image[1], second_position = ref3.position, second_unit = ref3.unit);
        if (!(start_change === 'any' || position === start_change.position && (unit === start_change.unit || position === 0) && second_position === start_change.second_position && (second_unit === start_change.second_unit || second_position === 0))) {
          continue;
        }
        return _change[image_index] = [{
          position: end_change.position,
          unit: end_change.unit
        }, {
          position: end_change.second_position,
          unit: end_change.second_unit
        }];
      }
      changed = null;
      for (k = 0, len1 = changing_vals_for_image.length; k < len1; k++) {
        ref4 = changing_vals_for_image[k], start_change = ref4.start, end_change = ref4.end, type = ref4.type;
        if (type !== 'full') {
          for (dim_index = l = 0, len2 = start_image.length; l < len2; dim_index = ++l) {
            ref5 = start_image[dim_index], position = ref5.position, unit = ref5.unit;
            if (!(start_change.position === position && start_change.unit === unit)) {
              continue;
            }
            (changed != null ? changed : changed = [])[dim_index] = {
              position: end_change.position,
              unit: end_change.unit
            };
          }
        }
      }
      if (changed != null) {
        return _change[image_index] = changed;
      }
    });
    return _change;
  };
  _css_val = function _css_val(arg1) {
    var dim_str, end, image_index, image_str, pos, start, start_image, tween;
    tween = arg1.tween;
    pos = tween.pos, start = tween.start, end = tween.end;
    dim_str = function dim_str(dim) {
      var position, unit;
      if (dim.position == null) {
        return dim;
      }
      position = dim.position, unit = dim.unit;
      return "" + position + unit;
    };
    image_str = function image_str(arg2) {
      var dim1, dim2;
      dim1 = arg2[0], dim2 = arg2[1];
      return dim_str(dim1) + " " + dim_str(dim2);
    };
    return function () {
      var j, len, results;
      results = [];
      for (image_index = j = 0, len = start.length; j < len; image_index = ++j) {
        start_image = start[image_index];
        results.push(function () {
          var dim, dim_index, end_change;
          end_change = end[image_index];
          if (end_change == null) {
            return image_str(start_image);
          }
          return function () {
            var k, len1, results1;
            results1 = [];
            for (dim_index = k = 0, len1 = start_image.length; k < len1; dim_index = ++k) {
              dim = start_image[dim_index];
              results1.push(function () {
                var dim_change;
                if (!(dim_change = end_change != null ? end_change[dim_index] : void 0)) {
                  return dim_str(dim);
                }
                return dim_str({
                  position: scaled({
                    start: dim,
                    end: dim_change,
                    pos: pos,
                    prop: 'position'
                  }),
                  unit: dim_change.unit
                });
              }());
            }
            return results1;
          }().join(' ').trim();
        }());
      }
      return results;
    }().join(', ');
  };
  register_animation_handler({
    prop_name: 'backgroundPosition',
    parse: function parse(val) {
      var all, dim, image, j, len, match, position, ref, rel_op, results, standardize_dims, unit;
      standardize_dims = function standardize_dims(image) {
        var presets, ref, unstandardized_dims;
        unstandardized_dims = image.split(/\s+/);
        if (unstandardized_dims.length === 1) {
          unstandardized_dims = (ref = unstandardized_dims[0]) === 'top' || ref === 'bottom' ? ['50%', unstandardized_dims[0]] : [unstandardized_dims[0], '50%'];
        }
        presets = {
          center: '50%',
          left: '0%',
          right: '100%',
          top: '0%',
          bottom: '100%'
        };
        return map(unstandardized_dims, function (dim) {
          var ref1;
          return "" + ((ref1 = presets[dim]) != null ? ref1 : dim);
        });
      };
      ref = (val || '').split(/\s*,\s*/);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        image = ref[j];
        results.push(function () {
          var k, len1, ref1, ref2, results1;
          ref1 = standardize_dims(image);
          results1 = [];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            dim = ref1[k];
            match = dim.match(RegExp("^" + relative_length_regex_chunk + "$"));
            all = match[0], rel_op = match[1], position = match[2], unit = (ref2 = match[3]) != null ? ref2 : 'px';
            results1.push({
              rel_op: rel_op,
              unit: unit,
              position: parseFloat(position)
            });
          }
          return results1;
        }());
      }
      return results;
    },
    init_tween_end: function init_tween_end(arg1) {
      var bg, end, parse, parsed, start, tween;
      tween = arg1.tween, parse = arg1.parse;
      start = tween.start, end = tween.end;
      if (_looks_like_shorthand(end)) {
        return _parse_shorthand({
          start: start,
          end: end
        });
      }
      parsed = parse(end);
      if (parsed.length === 1 && parsed.length < start.length) {
        parsed = function () {
          var j, len, results;
          results = [];
          for (j = 0, len = start.length; j < len; j++) {
            bg = start[j];
            results.push(parsed[0]);
          }
          return results;
        }();
      }
      return _extract_changes(normalize_rel_ops({
        parsed: parsed,
        start: start
      }));
    },
    css_val_from_initialized_tween: _css_val
  });
  register_animation_handler({
    prop_name: 'backgroundSize',
    parse: function parse(val) {
      var dim, dims, image, j, len, ref, results;
      ref = (val || '').split(/\s*,\s*/);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        image = ref[j];
        dims = function () {
          var supplied_dims;
          if (image === 'contain' || image === 'cover') {
            return [image, ''];
          }
          supplied_dims = image.split(/\s+/);
          if (supplied_dims.length !== 1) {
            return supplied_dims;
          }
          return [supplied_dims[0], 'auto'];
        }();
        results.push(function () {
          var k, len1, results1;
          results1 = [];
          for (k = 0, len1 = dims.length; k < len1; k++) {
            dim = dims[k];
            results1.push(function () {
              var all, match, position, ref1, rel_op, unit;
              match = dim.match(RegExp("^(?:" + relative_length_regex_chunk + "|auto)$"));
              if (!(match != null ? match[2] : void 0)) {
                return dim;
              }
              all = match[0], rel_op = match[1], position = match[2], unit = (ref1 = match[3]) != null ? ref1 : 'px';
              return {
                rel_op: rel_op,
                unit: unit,
                position: parseFloat(position)
              };
            }());
          }
          return results1;
        }());
      }
      return results;
    },
    init_tween_end: function init_tween_end(arg1) {
      var end, image, parse, parsed, start, tween;
      tween = arg1.tween, parse = arg1.parse;
      start = tween.start, end = tween.end;
      if (_looks_like_shorthand(end)) {
        return _parse_shorthand({
          start: start,
          end: end
        });
      }
      parsed = parse(end);
      if (parsed.length === 1 && parsed.length < start.length) {
        parsed = function () {
          var j, len, results;
          results = [];
          for (j = 0, len = start.length; j < len; j++) {
            image = start[j];
            results.push(parsed[0]);
          }
          return results;
        }();
      }
      return _extract_changes(normalize_rel_ops({
        parsed: parsed,
        start: start
      }));
    },
    css_val_from_initialized_tween: _css_val
  });
  color_regex_chunk = regex_chunk_str(/((?:rgba?\([^)]*\))|(?:hsla?\([^)]*\))|(?:\#[0-9A-Fa-f]+)|\w+)/);
  angle_or_direction_regex_chunk = regex_chunk_str(/(?:(-?\d+(?:.\d+)?)(deg|grad|rad|turn)|to\s+(bottom|top|left|right)(?:\s+(bottom|top|left|right))?)/);
  value_regex_chunk = regex_chunk_str(RegExp("(?:" + angle_or_direction_regex_chunk + "|" + length_regex_chunk + "|" + color_regex_chunk + ")"));
  angle_from_direction = function angle_from_direction(arg1) {
    var angle, first_direction, second_direction;
    angle = arg1.angle, first_direction = arg1.first_direction, second_direction = arg1.second_direction;
    if (angle) {
      return parseFloat(angle);
    }
    if (second_direction) {
      if ('top' === first_direction || 'top' === second_direction) {
        if ('left' === first_direction || 'left' === second_direction) {
          return 315;
        } else {
          return 45;
        }
      } else {
        if ('left' === first_direction || 'left' === second_direction) {
          return 225;
        } else {
          return 135;
        }
      }
    } else {
      return function () {
        if (!first_direction) {
          first_direction = 'bottom';
        }
        switch (first_direction) {
          case 'top':
            return 0;
          case 'bottom':
            return 180;
          case 'left':
            return 270;
          case 'right':
            return 90;
        }
      }();
    }
  };
  error = function error(msg) {
    throw new SyntaxError(msg);
  };
  gradient_handler = function gradient_handler(arg1) {
    var detect_gradient_type, function_name, hook_name, parse_gradient, pre_stops_css;
    function_name = arg1.function_name, hook_name = arg1.hook_name, parse_gradient = arg1.parse_gradient, detect_gradient_type = arg1.detect_gradient_type, pre_stops_css = arg1.pre_stops_css;
    return {
      hook_name: hook_name,
      prop_name: 'backgroundImage',
      init_tween_end: function init_tween_end(arg2) {
        var _change, _eq, _position, all, angle, base, base1, changed, changed_stop, changing_vals, changing_vals_for_image, color, color_change, end, end_change, extract_changes, image, image_index, j, k, l, len, len1, len2, len3, len4, len5, looks_like_shorthand, m, match, n, o, parse, pos_index, position, ref, ref1, ref2, ref3, ref4, start, start_change, stop, stop_index, stops, tween, type, unit, use_opacity;
        tween = arg2.tween, parse = arg2.parse;
        start = tween.start, end = tween.end;
        if (match = /^simultaneous\s*/.exec(end)) {
          all = match[0];
          start.simultaneous = true;
          end = end.slice(all.length);
        }
        extract_changes = function extract_changes(parsed_end) {
          var _change, base, base1, change_stop, changed, changed_stop, end_image, end_pos, end_stop, i, image_index, j, k, l, len, len1, len2, ref, ref1, start_image, start_pos, start_stop, stop_index;
          if (parsed_end.length !== start.length) {
            error("Animation end value '" + end + "' has " + parsed_end.length + " background images, but start value has " + start.length);
          }
          _change = [];
          for (image_index = j = 0, len = start.length; j < len; image_index = ++j) {
            start_image = start[image_index];
            if (!!is_string(start_image)) {
              continue;
            }
            end_image = parsed_end[image_index];
            if (is_string(end_image)) {
              error("Expected gradient in animation end value but got '" + end_image + "'");
            }
            if (end_image.stops.length !== start_image.stops.length) {
              error("Animation end value '" + end + "' has " + end_image.stops.length + " color stops, but start value has " + start_image.stops.length);
            }
            changed = null;
            if (start_image.angle != null && start_image.angle !== end_image.angle) {
              (changed != null ? changed : changed = {}).angle = end_image.angle;
            }
            if (start_image.position != null) {
              ref = start_image.position;
              for (i = k = 0, len1 = ref.length; k < len1; i = ++k) {
                start_pos = ref[i];
                end_pos = end_image.position[i];
                if (start_pos.position === end_pos.position) {
                  continue;
                }
                ((base = changed != null ? changed : changed = {}).position != null ? base.position : base.position = [])[i] = end_pos;
              }
            }
            ref1 = start_image.stops;
            for (stop_index = l = 0, len2 = ref1.length; l < len2; stop_index = ++l) {
              start_stop = ref1[stop_index];
              end_stop = end_image.stops[stop_index];
              changed_stop = null;
              change_stop = function change_stop(prop_name) {
                var obj1;
                return extend(changed_stop != null ? changed_stop : changed_stop = {}, (obj1 = {}, obj1["" + prop_name] = end_stop[prop_name], obj1));
              };
              if (start_stop.position !== end_stop.position) {
                change_stop('position');
              }
              if (start_stop.unit !== end_stop.unit) {
                change_stop('unit');
              }
              if (!Color.eq(start_stop.color, end_stop.color)) {
                change_stop('color');
              }
              if (changed_stop) {
                ((base1 = changed != null ? changed : changed = {}).stops != null ? base1.stops : base1.stops = [])[stop_index] = changed_stop;
              }
            }
            if (changed) {
              _change[image_index] = changed;
            }
          }
          return _change;
        };
        looks_like_shorthand = function looks_like_shorthand(end) {
          if (RegExp("\\s*" + value_regex_chunk + "(?:\\s+" + length_regex_chunk + ")?\\s*->|" + index_regex_chunk).exec(end)) {
            return true;
          }
        };
        if (!looks_like_shorthand(end)) {
          return extract_changes(parse(end));
        }
        changing_vals = function () {
          var angle, angle_unit, color, first_direction, index, indexed_parsed_pairs, pair, parsed_pairs, position, remaining, second_direction, second_position, second_unit, separator, set_from_match_params, unit;
          parsed_pairs = [];
          indexed_parsed_pairs = {};
          separator = null;
          index = null;
          remaining = end;
          while (remaining) {
            if (match = RegExp("^\\s*" + index_regex_chunk).exec(remaining)) {
              all = match[0], index = match[1];
              remaining = remaining.slice(all.length);
            }
            match = RegExp("^\\s*" + value_regex_chunk + "(?:[^\\n\\S]+" + length_regex_chunk + ")?\\s*->\\s*").exec(remaining);
            all = match[0], angle = match[1], angle_unit = match[2], first_direction = match[3], second_direction = match[4], position = match[5], unit = match[6], color = match[7], second_position = match[8], second_unit = match[9];
            pair = {
              type: function () {
                switch (false) {
                  case color == null:
                    return 'color';
                  case !(angle || first_direction):
                    return 'angle';
                  default:
                    return 'length';
                }
              }()
            };
            set_from_match_params = function set_from_match_params(start_or_end) {
              pair[start_or_end] = color != null ? {
                color: color
              } : angle || first_direction ? {
                angle: angle_from_direction({
                  angle: angle,
                  first_direction: first_direction,
                  second_direction: second_direction
                }),
                angle_unit: angle_unit
              } : {
                unit: unit,
                position: parseFloat(position)
              };
              if (second_position) {
                if (start_or_end === 'start') {
                  pair.type = 'full_stop';
                }
                return extend(pair[start_or_end], {
                  unit: second_unit,
                  position: parseFloat(second_position)
                });
              }
            };
            set_from_match_params('start');
            remaining = remaining.slice(all.length);
            match = RegExp("^" + value_regex_chunk + "(?:[^\\n\\S]+" + length_regex_chunk + ")?[^\\n\\S]*([,\\n])?\\s*").exec(remaining);
            all = match[0], angle = match[1], angle_unit = match[2], first_direction = match[3], second_direction = match[4], position = match[5], unit = match[6], color = match[7], second_position = match[8], second_unit = match[9], separator = match[10];
            set_from_match_params('end');
            (index != null ? indexed_parsed_pairs[index] != null ? indexed_parsed_pairs[index] : indexed_parsed_pairs[index] = [] : parsed_pairs).push(pair);
            remaining = remaining.slice(all.length);
          }
          return extended(indexed_parsed_pairs, {
            all: parsed_pairs
          });
        }();
        _change = [];
        for (image_index = j = 0, len = start.length; j < len; image_index = ++j) {
          image = start[image_index];
          changing_vals_for_image = changing_vals.all.slice(0).concat((ref = changing_vals[image_index]) != null ? ref : []);
          if (is_string(image)) {
            continue;
          }
          stops = image.stops, angle = image.angle, position = image.position;
          changed = null;
          if (angle != null) {
            for (k = 0, len1 = changing_vals_for_image.length; k < len1; k++) {
              ref1 = changing_vals_for_image[k], start_change = ref1.start, end_change = ref1.end, type = ref1.type;
              if (type === 'angle') {
                if (angle === start_change.angle) {
                  (changed != null ? changed : changed = {}).angle = end_change.angle;
                }
              }
            }
          }
          if (position != null) {
            for (l = 0, len2 = changing_vals_for_image.length; l < len2; l++) {
              ref2 = changing_vals_for_image[l], start_change = ref2.start, end_change = ref2.end, type = ref2.type;
              if (type === 'length') {
                for (pos_index = m = 0, len3 = position.length; m < len3; pos_index = ++m) {
                  ref3 = position[pos_index], _position = ref3.position, unit = ref3.unit;
                  if (start_change.position === _position && start_change.unit === unit) {
                    ((base = changed != null ? changed : changed = {}).position != null ? base.position : base.position = [])[pos_index] = {
                      position: end_change.position,
                      unit: end_change.unit
                    };
                  }
                }
              }
            }
          }
          for (stop_index = n = 0, len4 = stops.length; n < len4; stop_index = ++n) {
            stop = stops[stop_index];
            changed_stop = null;
            for (o = 0, len5 = changing_vals_for_image.length; o < len5; o++) {
              ref4 = changing_vals_for_image[o], start_change = ref4.start, end_change = ref4.end, type = ref4.type;
              switch (type) {
                case 'length':
                  position = start_change.position, unit = start_change.unit;
                  if (!(position === stop.position && unit === stop.unit)) {
                    continue;
                  }
                  extend(changed_stop != null ? changed_stop : changed_stop = {}, {
                    position: end_change.position,
                    unit: end_change.unit
                  });
                  break;
                case 'color':
                  color = start_change.color;
                  if (!(_eq = Color.eq(color, stop.color))) {
                    continue;
                  }
                  color_change = Color.create(end_change.color);
                  if (use_opacity = _eq != null ? _eq.opacity : void 0) {
                    color_change = Color.setAlpha(color_change, use_opacity);
                  }
                  extend(changed_stop != null ? changed_stop : changed_stop = {}, {
                    color: color_change
                  });
                  break;
                case 'full_stop':
                  position = start_change.position, unit = start_change.unit, color = start_change.color;
                  if (!(position === stop.position && unit === stop.unit && (_eq = Color.eq(color, stop.color)))) {
                    continue;
                  }
                  color_change = Color.create(end_change.color);
                  if (use_opacity = _eq != null ? _eq.opacity : void 0) {
                    color_change = Color.setAlpha(color_change, use_opacity);
                  }
                  extend(changed_stop != null ? changed_stop : changed_stop = {}, {
                    position: end_change.position,
                    unit: end_change.unit,
                    color: color_change
                  });
              }
            }
            if (changed_stop) {
              ((base1 = changed != null ? changed : changed = {}).stops != null ? base1.stops : base1.stops = [])[stop_index] = changed_stop;
            }
          }
          if (changed) {
            _change[image_index] = changed;
          }
        }
        return _change;
      },
      parse: function parse(val) {
        var _top_level_args, image, j, len, ref, results;
        _top_level_args = function _top_level_args(val) {
          return val.match(/[^\(,]*\((?:[^\(\)]+|[^\(\)]+\([^\)]+\)[^\(\)]*)+\)[^,]*|[^,]+/g);
        };
        ref = _top_level_args(val);
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          image = ref[j];
          results.push(function () {
            var detected_gradient_type, obj, parsed, stops_str;
            if (detect_gradient_type) {
              detected_gradient_type = detect_gradient_type(image);
              if (!detected_gradient_type) {
                return image;
              }
              function_name = detected_gradient_type.function_name, parse_gradient = detected_gradient_type.parse_gradient, pre_stops_css = detected_gradient_type.pre_stops_css;
            }
            parsed = parse_gradient({
              image: image,
              function_name: function_name
            });
            if (!(parsed != null ? parsed.stops_str : void 0)) {
              return parsed;
            }
            stops_str = parsed.stops_str, obj = parsed.obj;
            if (detect_gradient_type) {
              extend(obj, {
                pre_stops_css: pre_stops_css,
                function_name: function_name
              });
            }
            return extended(obj, {
              stops: function () {
                var all, assign_missing_stop_positions, color, fill_consecutive_missing_stop_positions, fill_in_missing, match, position, split_stops, stop, stop_index, stops, unit;
                split_stops = _top_level_args(stops_str);
                stops = function () {
                  var k, len1, results1;
                  results1 = [];
                  for (stop_index = k = 0, len1 = split_stops.length; k < len1; stop_index = ++k) {
                    stop = split_stops[stop_index];
                    match = RegExp("^\\s*" + color_regex_chunk + "(?:\\s+" + length_regex_chunk + ")?").exec(stop);
                    all = match[0], color = match[1], position = match[2], unit = match[3];
                    if (position == null) {
                      position = function () {
                        switch (stop_index) {
                          case split_stops.length - 1:
                            return 100;
                          default:
                            return 0;
                        }
                      }();
                      unit = '%';
                    }
                    results1.push({
                      color: Color.create(color),
                      position: position != null ? parseFloat(position) : void 0,
                      unit: unit != null ? unit : 'px'
                    });
                  }
                  return results1;
                }();
                fill_in_missing = function fill_in_missing(arg2) {
                  var current_position, following_stop_position, k, len1, missing, missing_stop, per, prev_stop_position, results1;
                  missing = arg2.missing, prev_stop_position = arg2.prev_stop_position, following_stop_position = arg2.following_stop_position;
                  per = (following_stop_position - prev_stop_position) / (missing.length + 1);
                  current_position = prev_stop_position;
                  results1 = [];
                  for (k = 0, len1 = missing.length; k < len1; k++) {
                    missing_stop = missing[k];
                    current_position += per;
                    results1.push(missing_stop.position = current_position);
                  }
                  return results1;
                };
                assign_missing_stop_positions = function assign_missing_stop_positions(arg2) {
                  var following_stop, following_stop_index, k, len1, missing, prev_stop_position, ref1, stop_index;
                  stop_index = arg2.stop_index, prev_stop_position = arg2.prev_stop_position;
                  missing = [stop];
                  ref1 = stops.slice(stop_index + 1);
                  for (following_stop_index = k = 0, len1 = ref1.length; k < len1; following_stop_index = ++k) {
                    following_stop = ref1[following_stop_index];
                    position = following_stop.position;
                    if (position != null) {
                      fill_in_missing({
                        missing: missing,
                        prev_stop_position: prev_stop_position,
                        following_stop_position: position
                      });
                      return stop_index + following_stop_index + 1;
                    } else {
                      missing.push(following_stop);
                    }
                  }
                };
                fill_consecutive_missing_stop_positions = function fill_consecutive_missing_stop_positions() {
                  var k, len1, prev_stop_position;
                  prev_stop_position = null;
                  for (stop_index = k = 0, len1 = stops.length; k < len1; stop_index = ++k) {
                    stop = stops[stop_index];
                    position = stop.position;
                    if (position == null) {
                      return assign_missing_stop_positions({
                        stop: stop,
                        stop_index: stop_index,
                        prev_stop_position: prev_stop_position
                      });
                    }
                    prev_stop_position = position;
                  }
                  return null;
                };
                while (fill_consecutive_missing_stop_positions()) {
                  null;
                }
                return stops;
              }()
            });
          }());
        }
        return results;
      },
      css_val_from_initialized_tween: function css_val_from_initialized_tween(arg2) {
        var current, end, get_current, image, image_index, parsed_tween, pos, start, tween;
        tween = arg2.tween, parsed_tween = arg2.parsed_tween;
        pos = tween.pos, start = tween.start, end = tween.end;
        current = null;
        get_current = function get_current() {
          var simultaneous;
          simultaneous = start.simultaneous;
          return current != null ? current : current = simultaneous ? parsed_tween(tween) : start;
        };
        return function () {
          var j, len, results;
          results = [];
          for (image_index = j = 0, len = start.length; j < len; image_index = ++j) {
            image = start[image_index];
            results.push(function () {
              var adjusted_stops, color, current_image, end_change, get_current_image, position, ref, ref1, unit;
              if (is_string(image)) {
                return image;
              }
              end_change = end[image_index];
              get_current_image = function get_current_image() {
                return get_current()[image_index];
              };
              current_image = get_current_image();
              adjusted_stops = function () {
                var k, len1, ref, results1, stop, stop_index;
                if (!(end_change != null ? end_change.stops : void 0)) {
                  return current_image.stops;
                }
                ref = image.stops;
                results1 = [];
                for (stop_index = k = 0, len1 = ref.length; k < len1; stop_index = ++k) {
                  stop = ref[stop_index];
                  results1.push(function () {
                    var color, color_change, current_stop, position, position_change, stop_change, unit;
                    color = stop.color, unit = stop.unit, position = stop.position;
                    current_stop = current_image.stops[stop_index];
                    if (!(stop_change = end_change.stops[stop_index])) {
                      return current_stop;
                    }
                    return {
                      color: (color_change = stop_change.color) ? Color.transition({
                        start: color,
                        end: color_change,
                        pos: pos
                      }) : current_stop.color,
                      position: (position_change = stop_change.position) ? scaled({
                        start: position,
                        end: position_change,
                        pos: pos
                      }) : current_stop.position,
                      unit: unit
                    };
                  }());
                }
                return results1;
              }();
              return ((ref = image.function_name) != null ? ref : function_name) + "(" + ((ref1 = image.pre_stops_css) != null ? ref1 : pre_stops_css)({
                start_gradient: image,
                end_change: end_change,
                pos: pos,
                get_current_image: get_current_image
              }) + function () {
                var k, len1, ref2, results1;
                results1 = [];
                for (k = 0, len1 = adjusted_stops.length; k < len1; k++) {
                  ref2 = adjusted_stops[k], color = ref2.color, position = ref2.position, unit = ref2.unit;
                  results1.push(color + " " + position + unit);
                }
                return results1;
              }().join(', ') + ")";
            }());
          }
          return results;
        }().join(', ');
      }
    };
  };
  parse_linear_gradient = function parse_linear_gradient(arg1) {
    var all, angle, angle_unit, first_direction, function_name, image, match, second_direction, stops_str;
    image = arg1.image, function_name = arg1.function_name;
    match = RegExp("^\\s*" + function_name + "\\(\\s*(?:" + angle_or_direction_regex_chunk + "\\s*,\\s*)?(.+)\\)\\s*$").exec(image);
    if (!match) {
      return image;
    }
    all = match[0], angle = match[1], angle_unit = match[2], first_direction = match[3], second_direction = match[4], stops_str = match[5];
    return {
      obj: {
        angle: angle_from_direction({
          angle: angle,
          first_direction: first_direction,
          second_direction: second_direction
        }),
        angle_unit: angle_unit != null ? angle_unit : 'deg'
      },
      stops_str: stops_str
    };
  };
  pre_stops_css_linear_gradient = function pre_stops_css_linear_gradient(arg1) {
    var angle_change, angle_unit, end_change, get_current_image, pos, start_gradient;
    start_gradient = arg1.start_gradient, end_change = arg1.end_change, pos = arg1.pos, get_current_image = arg1.get_current_image;
    angle_unit = start_gradient.angle_unit;
    return "" + ((angle_change = end_change != null ? end_change.angle : void 0) ? scaled({
      start: start_gradient.angle,
      end: angle_change,
      pos: pos
    }) : get_current_image().angle) + angle_unit + ", ";
  };
  register_animation_handler(gradient_handler({
    hook_name: 'linearGradient',
    function_name: 'linear-gradient',
    parse_gradient: parse_linear_gradient,
    pre_stops_css: pre_stops_css_linear_gradient
  }));
  register_animation_handler(gradient_handler({
    hook_name: 'repeatingLinearGradient',
    function_name: 'repeating-linear-gradient',
    parse_gradient: parse_linear_gradient,
    pre_stops_css: pre_stops_css_linear_gradient
  }));
  parse_radial_gradient = function parse_radial_gradient(arg1) {
    var all, extent1, extent2, extent_regex_chunk, function_name, image, keyword1, keyword2, match, position1, position2, position_regex_chunk, ref, shape1, shape2, shape_regex_chunk, single_position_regex_chunk, stops_str, unit1, unit2;
    image = arg1.image, function_name = arg1.function_name;
    shape_regex_chunk = regex_chunk_str(/(circle|ellipse)/);
    extent_regex_chunk = regex_chunk_str(/(closest-corner|closest-side|farthest-corner|farthest-side)/);
    single_position_regex_chunk = regex_chunk_str(RegExp("(?:(left|center|right|top|bottom)|" + length_regex_chunk + ")"));
    position_regex_chunk = regex_chunk_str(RegExp("at\\s+" + single_position_regex_chunk + "(?:\\s+" + single_position_regex_chunk + ")?"));
    match = RegExp("^\\s*" + function_name + "\\(\\s*(?:(?:" + shape_regex_chunk + "(?:\\s+" + extent_regex_chunk + ")?|" + extent_regex_chunk + "(?:\\s+" + shape_regex_chunk + ")?)?(?:\\s*" + position_regex_chunk + ")?\\s*,\\s*)?(.+)\\)\\s*$").exec(image);
    if (!match) {
      return image;
    }
    all = match[0], shape1 = match[1], extent1 = match[2], extent2 = match[3], shape2 = match[4], keyword1 = match[5], position1 = match[6], unit1 = match[7], keyword2 = match[8], position2 = match[9], unit2 = match[10], stops_str = match[11];
    return {
      obj: {
        shape: (ref = shape1 != null ? shape1 : shape2) != null ? ref : 'ellipse',
        extent: extent1 != null ? extent1 : extent2,
        position: function () {
          var first, first_is_second, from_keyword, second;
          from_keyword = function from_keyword(keyword) {
            switch (keyword) {
              case 'center':
                return {
                  position: 50,
                  unit: '%'
                };
              case 'top':
                return {
                  position: 0,
                  unit: '%'
                };
              case 'bottom':
                return {
                  position: 100,
                  unit: '%'
                };
              case 'left':
                return {
                  position: 0,
                  unit: '%'
                };
              case 'right':
                return {
                  position: 100,
                  unit: '%'
                };
            }
          };
          if (!(keyword1 != null || position1 != null)) {
            return [from_keyword('center'), from_keyword('center')];
          }
          first = keyword1 ? (first_is_second = keyword1 === 'top' || keyword1 === 'bottom', from_keyword(keyword1)) : {
            position: parseFloat(position1),
            unit: unit1
          };
          second = keyword2 != null || position2 != null ? keyword2 ? from_keyword(keyword2) : {
            position: parseFloat(position2),
            unit: unit2
          } : from_keyword('center');
          if (first_is_second) {
            return [second, first];
          } else {
            return [first, second];
          }
        }()
      },
      stops_str: stops_str
    };
  };
  pre_stops_css_radial_gradient = function pre_stops_css_radial_gradient(arg1) {
    var angle_change, angle_unit, current_pos, end_change, extent, get_current_image, pos, pos_index, position, position_change, ref, shape, start_gradient;
    start_gradient = arg1.start_gradient, end_change = arg1.end_change, pos = arg1.pos, get_current_image = arg1.get_current_image;
    angle_unit = start_gradient.angle_unit;
    "" + ((angle_change = end_change != null ? end_change.angle : void 0) ? scaled({
      start: start_gradient.angle,
      end: angle_change,
      pos: pos
    }) : get_current_image().angle) + angle_unit + ", ";
    shape = start_gradient.shape, extent = start_gradient.extent, position = start_gradient.position;
    return "" + shape + (extent ? " " + extent : '') + " at " + ((position_change = end_change != null ? end_change.position : void 0) ? function () {
      var j, len, ref, results;
      ref = [0, 1];
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        pos_index = ref[j];
        results.push("" + (position_change[pos_index] ? scaled({
          start: position[pos_index].position,
          end: position_change[pos_index].position,
          pos: pos
        }) : get_current_image().position[pos_index].position) + position[pos_index].unit);
      }
      return results;
    }().join(' ') : ((ref = get_current_image(), current_pos = ref.position, ref), "" + current_pos[0].position + current_pos[0].unit + " " + current_pos[1].position + current_pos[1].unit)) + ", ";
  };
  register_animation_handler(gradient_handler({
    hook_name: 'radialGradient',
    function_name: 'radial-gradient',
    parse_gradient: parse_radial_gradient,
    pre_stops_css: pre_stops_css_radial_gradient
  }));
  return register_animation_handler(gradient_handler({
    detect_gradient_type: function detect_gradient_type(image) {
      var all, function_name, match;
      match = /^\s*(linear-gradient|repeating-linear-gradient|radial-gradient|repeating-radial-gradient)\(/.exec(image);
      if (!match) {
        return;
      }
      all = match[0], function_name = match[1];
      return extended({
        function_name: function_name
      }, function () {
        switch (function_name) {
          case 'linear-gradient':
          case 'repeating-linear-gradient':
            return {
              parse_gradient: parse_linear_gradient,
              pre_stops_css: pre_stops_css_linear_gradient
            };
          default:
            return {
              parse_gradient: parse_radial_gradient,
              pre_stops_css: pre_stops_css_radial_gradient
            };
        }
      }());
    }
  }));
};

var extend,
    extended,
    is_string,
    map,
    slice = [].slice;

is_string = function is_string(obj) {
  return Object.prototype.toString.call(obj) === '[object String]';
};

map = function map(arr, clb) {
  var elem, i, j, len, results;
  results = [];
  for (i = j = 0, len = arr.length; j < len; i = ++j) {
    elem = arr[i];
    results.push(clb(elem, i));
  }
  return results;
};

extend = function extend() {
  var _obj, j, key, len, obj, objs, val;
  obj = arguments[0], objs = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  for (j = 0, len = objs.length; j < len; j++) {
    _obj = objs[j];
    for (key in _obj) {
      val = _obj[key];
      obj[key] = val;
    }
  }
  return obj;
};

extended = function extended() {
  var obj, objs;
  obj = arguments[0], objs = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  return extend.apply(null, [{}, obj].concat(slice.call(objs)));
};

;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _jquery = __webpack_require__(2);

var _jquery2 = _interopRequireDefault(_jquery);

__webpack_require__(3);

var _animateBackgrounds = __webpack_require__(0);

var _animateBackgrounds2 = _interopRequireDefault(_animateBackgrounds);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var Color, Tween, extend;

Tween = _jquery2.default.Tween, Color = _jquery2.default.Color, extend = _jquery2.default.extend;

extend(Color.names, {
  aliceblue: '#f0f8ff',
  antiquewhite: '#faebd7',
  aqua: '#00ffff',
  aquamarine: '#7fffd4',
  azure: '#f0ffff',
  beige: '#f5f5dc',
  bisque: '#ffe4c4',
  black: '#000000',
  blanchedalmond: '#ffebcd',
  blue: '#0000ff',
  blueviolet: '#8a2be2',
  brown: '#a52a2a',
  burlywood: '#deb887',
  cadetblue: '#5f9ea0',
  chartreuse: '#7fff00',
  chocolate: '#d2691e',
  coral: '#ff7f50',
  cornflowerblue: '#6495ed',
  cornsilk: '#fff8dc',
  crimson: '#dc143c',
  cyan: '#00ffff',
  darkblue: '#00008b',
  darkcyan: '#008b8b',
  darkgoldenrod: '#b8860b',
  darkgray: '#a9a9a9',
  darkgreen: '#006400',
  darkgrey: '#a9a9a9',
  darkkhaki: '#bdb76b',
  darkmagenta: '#8b008b',
  darkolivegreen: '#556b2f',
  darkorange: '#ff8c00',
  darkorchid: '#9932cc',
  darkred: '#8b0000',
  darksalmon: '#e9967a',
  darkseagreen: '#8fbc8f',
  darkslateblue: '#483d8b',
  darkslategray: '#2f4f4f',
  darkslategrey: '#2f4f4f',
  darkturquoise: '#00ced1',
  darkviolet: '#9400d3',
  deeppink: '#ff1493',
  deepskyblue: '#00bfff',
  dimgray: '#696969',
  dimgrey: '#696969',
  dodgerblue: '#1e90ff',
  firebrick: '#b22222',
  floralwhite: '#fffaf0',
  forestgreen: '#228b22',
  fuchsia: '#ff00ff',
  gainsboro: '#dcdcdc',
  ghostwhite: '#f8f8ff',
  gold: '#ffd700',
  goldenrod: '#daa520',
  gray: '#808080',
  green: '#008000',
  greenyellow: '#adff2f',
  grey: '#808080',
  honeydew: '#f0fff0',
  hotpink: '#ff69b4',
  indianred: '#cd5c5c',
  indigo: '#4b0082',
  ivory: '#fffff0',
  khaki: '#f0e68c',
  lavender: '#e6e6fa',
  lavenderblush: '#fff0f5',
  lawngreen: '#7cfc00',
  lemonchiffon: '#fffacd',
  lightblue: '#add8e6',
  lightcoral: '#f08080',
  lightcyan: '#e0ffff',
  lightgoldenrodyellow: '#fafad2',
  lightgray: '#d3d3d3',
  lightgreen: '#90ee90',
  lightgrey: '#d3d3d3',
  lightpink: '#ffb6c1',
  lightsalmon: '#ffa07a',
  lightseagreen: '#20b2aa',
  lightskyblue: '#87cefa',
  lightslategray: '#778899',
  lightslategrey: '#778899',
  lightsteelblue: '#b0c4de',
  lightyellow: '#ffffe0',
  lime: '#00ff00',
  limegreen: '#32cd32',
  linen: '#faf0e6',
  magenta: '#ff00ff',
  maroon: '#800000',
  mediumaquamarine: '#66cdaa',
  mediumblue: '#0000cd',
  mediumorchid: '#ba55d3',
  mediumpurple: '#9370db',
  mediumseagreen: '#3cb371',
  mediumslateblue: '#7b68ee',
  mediumspringgreen: '#00fa9a',
  mediumturquoise: '#48d1cc',
  mediumvioletred: '#c71585',
  midnightblue: '#191970',
  mintcream: '#f5fffa',
  mistyrose: '#ffe4e1',
  moccasin: '#ffe4b5',
  navajowhite: '#ffdead',
  navy: '#000080',
  oldlace: '#fdf5e6',
  olive: '#808000',
  olivedrab: '#6b8e23',
  orange: '#ffa500',
  orangered: '#ff4500',
  orchid: '#da70d6',
  palegoldenrod: '#eee8aa',
  palegreen: '#98fb98',
  paleturquoise: '#afeeee',
  palevioletred: '#db7093',
  papayawhip: '#ffefd5',
  peachpuff: '#ffdab9',
  peru: '#cd853f',
  pink: '#ffc0cb',
  plum: '#dda0dd',
  powderblue: '#b0e0e6',
  purple: '#800080',
  rebeccapurple: '#663399',
  red: '#ff0000',
  rosybrown: '#bc8f8f',
  royalblue: '#4169e1',
  saddlebrown: '#8b4513',
  salmon: '#fa8072',
  sandybrown: '#f4a460',
  seagreen: '#2e8b57',
  seashell: '#fff5ee',
  sienna: '#a0522d',
  silver: '#c0c0c0',
  skyblue: '#87ceeb',
  slateblue: '#6a5acd',
  slategray: '#708090',
  slategrey: '#708090',
  snow: '#fffafa',
  springgreen: '#00ff7f',
  steelblue: '#4682b4',
  tan: '#d2b48c',
  teal: '#008080',
  thistle: '#d8bfd8',
  tomato: '#ff6347',
  turquoise: '#40e0d0',
  violet: '#ee82ee',
  wheat: '#f5deb3',
  white: '#ffffff',
  whitesmoke: '#f5f5f5',
  yellow: '#ffff00',
  yellowgreen: '#9acd32'
});

(0, _animateBackgrounds2.default)({
  Color: {
    eq: function eq(a, b) {
      return Color(a).is(b);
    },
    create: Color,
    setAlpha: function setAlpha(color, val) {
      return color.alpha(val);
    },
    transition: function transition(arg) {
      var end, pos, start;
      start = arg.start, end = arg.end, pos = arg.pos;
      return start.transition(end, pos);
    }
  },
  hook: function hook(arg) {
    var css_val_from_initialized_tween, hook_name, init, init_tween_end, parse, parsed_tween, prop_name;
    hook_name = arg.hook_name, prop_name = arg.prop_name, css_val_from_initialized_tween = arg.css_val_from_initialized_tween, parsed_tween = arg.parsed_tween, parse = arg.parse, init_tween_end = arg.init_tween_end, init = arg.init;
    return Tween.propHooks[hook_name != null ? hook_name : prop_name] = {
      get: parsed_tween,
      set: function set(tween) {
        if (!tween.set) {
          init(tween);
        }
        return (0, _jquery2.default)(tween.elem).css(prop_name, css_val_from_initialized_tween({
          tween: tween,
          parsed_tween: parsed_tween
        }));
      }
    };
  }
});

/***/ }),
/* 2 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_2__;

/***/ }),
/* 3 */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_3__;

/***/ })
/******/ ]);
});