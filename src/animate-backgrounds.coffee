import $ from 'jquery'
import 'jquery-color'
{ extend, Tween, Color } = $

is_string = (obj) ->
  'string' is $.type obj

# background-position logic and general approach from Extending jQuery

map = (arr, clb) ->
  clb elem, i for elem, i in arr
extended = (obj, objs...) ->
  extend {}, obj, objs...

export default (hook) ->
  register_animation_handler = ({
    prop_name, hook_name
    parse
    init_tween_end
    css_val_from_initialized_tween
  }) ->
    parsed_tween = (tween) ->
      parse $(tween.elem).css prop_name

    init = ( tween ) ->
      tween.start = parsed_tween tween

      tween.end = init_tween_end { tween, parse }

      tween.set = yes

      console.log {tween}

    hook {
      prop_name, hook_name
      parse, parsed_tween
      init_tween_end, init
      css_val_from_initialized_tween
    }

  register_animation_handler
    prop_name: 'backgroundPosition'
    parse: (val) ->
      for bg in (val || '').split /\s*,\s*/
        dims = do ->
          unstandardized_dims = bg.split /\s+/

          if unstandardized_dims.length is 1
            unstandardized_dims =
              if unstandardized_dims[0] in ['top', 'bottom']
                [
                  '50%'
                  unstandardized_dims[0]
                ]
              else
                [
                  unstandardized_dims[0]
                  '50%'
                ]

          map(
            unstandardized_dims
            ( dim ) ->
              presets =
                center: '50%'
                left:   '0%'
                right:  '100%'
                top:    '0%'
                bottom: '100%'

              "#{ presets[dim] or dim }"
          )

        for dim in dims
          _match =
            dim
            .match ///
              ^
              ( # relative
               [+-]
               =
              ) ?
              ( # numeric value
               [+-] ?
               \d +
               (?:
                \.
                \d *
               ) ?
              )
              ( # unit
               . *
              )
              $
            ///

          rel_op: _match[1]
          amount: parseFloat _match[2]
          unit: _match[3] or 'px'

    init_tween_end: ({tween, parse}) ->
      { start, end } = tween

      parsed = parse end
      if parsed.length is 1 and parsed.length < start.length
        parsed =
          # repeat parsed[0], start.length
          for bg in start
            parsed[0]
      for endBg, bgIndex in parsed
        map endBg, ( val, i ) ->
          {rel_op, amount} = val
          return val unless rel_op

          val.amount =
            start[bgIndex][i].amount +
              amount * if rel_op is '-=' then -1 else 1

          val

    css_val_from_initialized_tween: ({tween}) ->
      {
        pos
        start
        end
      } = tween

      (
        for bgStart, bgIndex in start
          bgEnd = end[bgIndex]

          _span = ( dim ) ->
            bgEnd[dim].amount - bgStart[dim].amount
          _adjusted = ( dim ) ->
            bgStart[dim].amount + pos * _span dim
          ( "#{ _adjusted dim }#{ bgStart[dim].unit }" for dim in [0, 1])
          .join ' '
      )
      .join ', '

  register_animation_handler
    prop_name: 'backgroundSize'
    parse: (val) ->
      for bg in (val || '').split /\s*,\s*/
        dims = do ->
          return [bg, ''] if bg in ['contain', 'cover']

          supplied_dims = bg.split /\s+/

          return supplied_dims unless supplied_dims.length is 1

          [
            supplied_dims[0]
            'auto'
          ]

        for dim in dims
          _match =
            dim
            .match ///
              ^
              (?:
               (?: # non-keyword (ie numeric) value
                ( # relative
                 [+-]
                 =
                ) ?
                ( # numeric value
                 [+-] ?
                 \d +
                 (?:
                  \.
                  \d *
                 ) ?
                )
                ( # unit
                 . *
                )
               )
               | auto
              )
              $
            ///

          unless _match?[2]
            dim
          else
            rel_op: _match[1]
            amount: parseFloat _match[2]
            unit: _match[3] or 'px'

    init_tween_end: ({tween, parse}) ->
      {start, end} = tween

      parsed = parse end
      if parsed.length is 1 and parsed.length < start.length
        parsed =
          # repeat parsed[0], start.length
          for bg in start
            parsed[0]
      for endBg, bgIndex in parsed
        map endBg, (val, i) ->
          return val unless val?.unit
          {rel_op, amount} = val
          return val unless rel_op

          val.amount =
            start[bgIndex][i].amount +
              amount * if rel_op is '-=' then -1 else 1

          val

    css_val_from_initialized_tween: ({tween}) ->
      {
        pos
        start
        end
      } = tween

      (
        for bg_start, bg_index in start
          bg_end = end[bg_index]

          _span = ( dim ) ->
            bg_end[dim].amount - bg_start[dim].amount
          _adjusted = ( dim ) ->
            bg_start[dim].amount + pos * _span dim
          (
            for dim in [0, 1]
              bg_start_dim = bg_start[dim]
              if bg_start_dim?.unit
                "#{ _adjusted dim }#{ bg_start_dim.unit }"
              else bg_start_dim
          )
          .join ' '
          .trim()
      )
      .join ', '

  _int = (str) ->
    parseInt str, 10

  regex_chunk_str = (regex) ->
    [all, chunk] =
      ///
        ^
        /
        ( . * )
        /
        [^/] *
        $
      ///.exec regex.toString()
    chunk

  length_regex_chunk = regex_chunk_str ///
    (?:
      ( # position
        [+-] ?
        \d +
        (?:
          \.
          \d *
        ) ?
      )
      ( # unit
        %
        |
        \w +
      )
    )
  ///

  color_regex_chunk = regex_chunk_str ///
    ( # color
      (?: # rgb(a)
        rgba?\(
        [^)] *
        \)
      )
      |
      (?: # rgb(a)
        hsla?\(
        [^)] *
        \)
      )
      |
      (?: # hex
        \#
        [0-9A-Fa-f] +
      )
      |
      \w + # color name / transparent
    )
  ///

  scaled = ({start, end, pos, prop}) ->
    if prop
      if is_string prop
        prop = do (prop) ->
          (val) -> val[prop]
      start = prop start
      end   = prop end
    val = start + pos * (end - start)
    val

  color_eq = (a, b) ->
    a = Color a unless a instanceof Color
    b = Color b unless b instanceof Color
    return no for component, component_index in a._rgba[0..2] when b._rgba[component_index] isnt component
    return yes if a._rgba[3] is b._rgba[3]
    opacity: b._rgba[3]

  angle_or_direction_regex_chunk = regex_chunk_str ///
    (?: # angle or directions
      ( # angle
        - ?
        \d +
        (?:
          .
          \d +
        ) ?
      )
      (deg | grad | rad | turn) # unit
      |
      to
      \s +
      ( # first direction
        bottom | top | left | right
      )
      (?: # second direction
        \s +
        ( bottom | top | left | right )
      )?
    )
  ///

  value_regex_chunk = regex_chunk_str ///
    (?:
      #{angle_or_direction_regex_chunk}
      |
      #{length_regex_chunk}
      |
      #{color_regex_chunk}
    )
  ///

  index_regex_chunk = regex_chunk_str ///
    (?:
      \[
      (\d +)
      \]
    )
  ///

  angle_from_direction = ({angle, first_direction, second_direction}) ->
    return _int angle if angle
    if second_direction
      # TODO: error if first_direction same as second_direction or eg top bottom
      if 'top' in [first_direction, second_direction]
        if 'left' in [first_direction, second_direction]
          315
        else
          45
      else
        if 'left' in [first_direction, second_direction]
          225
        else
          135
    else do ->
      first_direction = 'bottom' unless first_direction
      switch first_direction
        when 'top'    then 0
        when 'bottom' then 180
        when 'left'   then 270
        when 'right'  then 90
        else # TODO: error

  gradient_handler = ({function_name, hook_name, parse_gradient, detect_gradient_type, pre_stops_css}) -> {
    hook_name
    prop_name: 'backgroundImage'

    init_tween_end: ({tween, parse}) ->
      {start, end} = tween

      looks_like_shorthand = (end) ->
        return yes if ///
          \s *
          #{value_regex_chunk}
          (?:
            \s +
            #{length_regex_chunk}
          ) ?
          \s *
          ->
          |
          #{index_regex_chunk}
        ///.exec end
      return parse end unless looks_like_shorthand end # TODO: error if end doesn't match start eg wrong # of background images/stops

      changing_vals = do ->
        parsed_pairs         = []
        indexed_parsed_pairs = {}
        separator = null
        index     = null
        remaining = end
        while remaining
          # TODO: error if parsed_pairs.length and not separator
          # TODO: move regexes to top level for optimization
          if match = ///
            ^
            \s *
            #{index_regex_chunk}
          ///.exec remaining
            [all, index] = match
            remaining = remaining[all.length..]

          # if match = ///
          #   ^
          #   \s *
          #   #{index_regex_chunk}
          # ///.exec remaining
          #   [all, stop_index] = match
          #   remaining = remaining[all.length..]

          match = ///
            ^
            \s *
            #{value_regex_chunk}
            (?:
              [^\n\S] +
              #{length_regex_chunk}
            ) ?
            \s *
            ->
            \s *
          ///.exec remaining
          [
            all
            angle, angle_unit, first_direction, second_direction
            position, unit
            color
            second_position, second_unit
          ] = match
          pair =
            type: switch
              when color?
                'color'
              when angle or first_direction
                'angle'
              else
                'length'
          set_from_match_params = (start_or_end) ->
            pair[start_or_end] =
              if color?
                {color}
              else if angle or first_direction
                {
                  angle: angle_from_direction {angle, first_direction, second_direction}
                  angle_unit
                }
              else
                {unit, position: _int position}
            if second_position
              pair.type = 'full_stop' if start_or_end is 'start' # TODO: error if only start or end is a full stop?
              extend pair[start_or_end],
                unit: second_unit
                position: _int second_position
          set_from_match_params 'start'

          remaining = remaining[all.length..]
          match =
            ///
              ^
              #{value_regex_chunk}
              (?:
                [^\n\S] +
                #{length_regex_chunk}
              ) ?
              [^\n\S] *
              ([,\n]) ?
              \s *
            ///.exec remaining
          [
            all
            angle, angle_unit, first_direction, second_direction
            position, unit
            color
            second_position, second_unit
            separator
          ] = match
          set_from_match_params 'end' # TODO: check that same type as start?
          (if index?
            indexed_parsed_pairs[index] ?= []
          else
            parsed_pairs
          ).push pair
          remaining = remaining[all.length..]

        extended indexed_parsed_pairs,
          all: parsed_pairs

      _change: do ->
        _change = []
        for image, image_index in start
          changing_vals_for_image =
            changing_vals.all[..]
            .concat(changing_vals[image_index] ? [])
          continue if is_string image
          {stops, angle} = image
          changed = null
          for {start: start_change, end: end_change, type} in changing_vals_for_image when type is 'angle'
            if angle is start_change.angle
              (changed ?= {}).angle = end_change.angle
          for stop, stop_index in stops
            changed_stop = null
            for {start: start_change, end: end_change, type} in changing_vals_for_image
              switch type
                when 'length'
                  {position, unit} = start_change
                  continue unless position is stop.position and unit is stop.unit
                  extend (changed_stop ?= {}),
                    position: end_change.position
                    unit:     end_change.unit
                when 'color'
                  {color} = start_change
                  continue unless _eq=color_eq color, stop.color
                  color_change = Color end_change.color
                  if use_opacity=_eq?.opacity
                    color_change = color_change.alpha use_opacity
                  extend (changed_stop ?= {}),
                    color: color_change
                when 'full_stop'
                  {position, unit, color} = start_change
                  continue unless position is stop.position and unit is stop.unit and _eq=color_eq color, stop.color
                  color_change = Color end_change.color
                  if use_opacity=_eq?.opacity
                    color_change = color_change.alpha use_opacity
                  extend (changed_stop ?= {}),
                    position: end_change.position
                    unit:     end_change.unit
                    color:    color_change
            ((changed ?= {}).stops ?= [])[stop_index] = changed_stop if changed_stop
          _change[image_index] = changed if changed
        _change # TODO: warn/error if no detected changes? warn for each changing_val that wasn't found anywhere?

    parse: (val) ->
      _top_level_args = (val) ->
        val.match ///
          [^\(,] *
          \(
          (?:
           [^\(\)] +
            |
           [^\(\)] +
           \(
            [^\)] +
           \)
           [^\(\)] *
          ) +
          \)
          [^,] *
           |
          [^,] +
        ///g

      for image in _top_level_args val then do ->
        if detect_gradient_type
          detected_gradient_type = detect_gradient_type image
          return image unless detected_gradient_type
          {function_name, parse_gradient, pre_stops_css} = detected_gradient_type
        parsed = parse_gradient {image, function_name}
        return parsed unless parsed?.stops_str
        {stops_str, obj} = parsed
        extend obj, {pre_stops_css, function_name} if detect_gradient_type
        extended obj,
          stops: do ->
            split_stops = _top_level_args stops_str
            stops =
              for stop, stop_index in split_stops
                match = ///
                  ^
                  \s *
                  #{color_regex_chunk}
                  (?:
                    \s +
                    #{length_regex_chunk}
                  ) ?
                ///.exec stop
                # TODO: error if no match
                [all, color, position, unit] = match
                unless position?
                  position =
                    switch stop_index
                      when 0
                        0
                      when split_stops.length - 1
                        100
                  unit = '%'

                color:
                  Color color
                position:
                  _int position if position?
                unit:
                  unit ? 'px'

            fill_in_missing = ({missing, prev_stop_position, following_stop_position}) ->
              # TODO: should check that units match? otherwise error ie presumably can't space between px and %?
              per = (following_stop_position - prev_stop_position) / (missing.length + 1)
              current_position = prev_stop_position
              for missing_stop in missing
                current_position += per
                missing_stop.position = current_position

            assign_missing_stop_positions = ({stop_index, prev_stop_position}) ->
              missing = [stop]
              for following_stop, following_stop_index in stops[stop_index + 1..]
                {position} = following_stop
                if position?
                  fill_in_missing {missing, prev_stop_position, following_stop_position: position}
                  return stop_index + following_stop_index + 1
                else
                  missing.push following_stop

            fill_consecutive_missing_stop_positions = ->
              prev_stop_position = null
              for stop, stop_index in stops
                {position} = stop
                return assign_missing_stop_positions {stop, stop_index, prev_stop_position} unless position?

                prev_stop_position = position
              null
            null while do fill_consecutive_missing_stop_positions
            stops

    css_val_from_initialized_tween: ({tween, parsed_tween}) ->
      {pos, start, end} = tween
      {_change} = end
      current = null
      get_current = ->
        current ?= parsed_tween tween

      (for image, image_index in start then do ->
        return image if is_string image

        if _change
          end_change = _change[image_index]
          current_image = get_current()[image_index]
        end_image = end[image_index]

        _scaled = (prop) ->
          scaled {
            start: image
            end: end_image
            pos, prop
          }

        adjusted_stops =
          for stop, stop_index in image.stops
            {color, unit, position} = stop

            if _change
              current_stop = current_image.stops[stop_index]
              if stop_change=end_change?.stops?[stop_index]
                {
                  color:
                    if color_change=stop_change.color
                      color.transition color_change, pos
                    else
                      current_stop.color
                  position:
                    if position_change=stop_change.position
                      scaled {
                        start: position
                        end: position_change
                        pos
                      }
                    else
                      current_stop.position
                  unit
                }
              else
                current_stop
            else {
              color:
                color.transition end_image.stops[stop_index].color, pos
              position:
                _scaled ({stops}) -> stops[stop_index].position
              unit
            }

        "#{image.function_name ? function_name}(#{
          (image.pre_stops_css ? pre_stops_css) {
            start_gradient: image
            end_gradient: end_image
            end_change, _change
            pos
            get_current_image: ->
              (current ?= parsed_tween tween)[image_index]
          }
        }#{
          ("#{color} #{position}#{unit}" for {color, position, unit} in adjusted_stops)
          .join ', '
        })"
      )
      .join ', '
  }

  parse_linear_gradient = ({image, function_name}) ->
    match = ///
      ^
      \s *
      #{function_name}\(
      \s *
      (?: # optional angle/direction
        #{angle_or_direction_regex_chunk}
        \s *
        ,
        \s *
      ) ?
      ( # stops
        . +
      )
      \)
      \s *
      $
    ///.exec image
    return image unless match
    [all, angle, angle_unit, first_direction, second_direction, stops_str] = match

    {
      obj: {
        angle: angle_from_direction {angle, first_direction, second_direction}
        angle_unit: angle_unit ? 'deg'
      }
      stops_str
    }

  pre_stops_css_linear_gradient = ({start_gradient, end_gradient, end_change, _change, pos, get_current_image}) ->
    {angle_unit} = start_gradient

    "#{
      if _change
        if angle_change=end_change?.angle
          scaled {
            start: start_gradient.angle
            end: angle_change
            pos
          }
        else
          get_current_image()
          .angle
      else
        scaled {
          start: start_gradient
          end: end_gradient
          pos
          prop: 'angle'
        }
    }#{angle_unit}, "

  register_animation_handler gradient_handler
    hook_name: 'linearGradient'
    function_name: 'linear-gradient'
    parse_gradient: parse_linear_gradient
    pre_stops_css: pre_stops_css_linear_gradient

  register_animation_handler gradient_handler
    hook_name: 'repeatingLinearGradient'
    function_name: 'repeating-linear-gradient'
    parse_gradient: parse_linear_gradient
    pre_stops_css: pre_stops_css_linear_gradient

  parse_radial_gradient = ({image, function_name}) ->
    shape_regex_chunk = regex_chunk_str ///
      (circle | ellipse)
    ///
    extent_regex_chunk = regex_chunk_str ///
      (closest-corner | closest-side | farthest-corner | farthest-side)
    ///
    single_position_regex_chunk = regex_chunk_str ///
      (?:
        (left | center | right | top | bottom)
        |
        #{length_regex_chunk}
      )
    ///
    position_regex_chunk = regex_chunk_str /// # TODO: handle syntax eg left 10px bottom 10px
      at
      \s +
      #{single_position_regex_chunk}
      (?:
        \s +
        #{single_position_regex_chunk}
      ) ?
    ///

    match = ///
      ^
      \s *
      #{function_name}\(
      \s *
      (?: # optional shape/extent/position TODO: handle length/percentages instead of circle/ellipse
        (?:
          #{shape_regex_chunk}
          (?:
            \s +
            #{extent_regex_chunk}
          ) ?
          |
          #{extent_regex_chunk}
          (?:
            \s +
            #{shape_regex_chunk}
          ) ?
        ) ?
        (?:
          \s *
          #{position_regex_chunk}
        ) ?
        \s *
        ,
        \s *
      ) ?
      ( # stops
        . +
      )
      \)
      \s *
      $
    ///.exec image
    return image unless match
    [
      all
      shape1, extent1
      extent2, shape2
      keyword1, position1, unit1
      keyword2, position2, unit2
      stops_str
    ] = match

    {
      obj:
        shape:
          shape1 ? shape2 ? 'ellipse'
        extent:
          extent1 ? extent2
        position: do ->
          from_keyword = (keyword) ->
            switch keyword
              when 'center' then position: 50,  unit: '%'
              when 'top'    then position: 0,   unit: '%'
              when 'bottom' then position: 100, unit: '%'
              when 'left'   then position: 0,   unit: '%'
              when 'right'  then position: 100, unit: '%'

          return [
            from_keyword 'center'
            from_keyword 'center'
          ] unless keyword1? or position1?

          first =
            if keyword1
              first_is_second = keyword1 in ['top', 'bottom']
              from_keyword keyword1
            else
              position: position1, unit: unit1
          second =
            if keyword2? or position2?
              if keyword2
                from_keyword keyword2
              else
                position: position2, unit: unit2
            else
              from_keyword 'center'

          if first_is_second
            [second, first]
          else
            [first, second]
      stops_str
    }

  pre_stops_css_radial_gradient = ({start_gradient, end_gradient, end_change, pos}) ->
    {shape, extent, position} = start_gradient

    # TODO: animate position
    "#{shape}#{
      if extent
        " #{extent}"
      else ''
    } at #{position[0].position}#{position[0].unit} #{position[1].position}#{position[1].unit}, "

  register_animation_handler gradient_handler
    hook_name: 'radialGradient'
    function_name: 'radial-gradient'
    parse_gradient: parse_radial_gradient
    pre_stops_css: pre_stops_css_radial_gradient

  register_animation_handler gradient_handler
    detect_gradient_type: (image) ->
      match = ///
        ^
        \s *
        (linear-gradient | repeating-linear-gradient | radial-gradient | repeating-radial-gradient)
        \(
      ///.exec image
      return unless match
      [all, function_name] = match
      extended {function_name},
        switch function_name
          when 'linear-gradient', 'repeating-linear-gradient'
            parse_gradient: parse_linear_gradient
            pre_stops_css: pre_stops_css_linear_gradient
          else
            parse_gradient: parse_radial_gradient
            pre_stops_css: pre_stops_css_radial_gradient

  extend Color.names,
    aliceblue: '#f0f8ff'
    antiquewhite: '#faebd7'
    aqua: '#00ffff'
    aquamarine: '#7fffd4'
    azure: '#f0ffff'
    beige: '#f5f5dc'
    bisque: '#ffe4c4'
    black: '#000000'
    blanchedalmond: '#ffebcd'
    blue: '#0000ff'
    blueviolet: '#8a2be2'
    brown: '#a52a2a'
    burlywood: '#deb887'
    cadetblue: '#5f9ea0'
    chartreuse: '#7fff00'
    chocolate: '#d2691e'
    coral: '#ff7f50'
    cornflowerblue: '#6495ed'
    cornsilk: '#fff8dc'
    crimson: '#dc143c'
    cyan: '#00ffff'
    darkblue: '#00008b'
    darkcyan: '#008b8b'
    darkgoldenrod: '#b8860b'
    darkgray: '#a9a9a9'
    darkgreen: '#006400'
    darkgrey: '#a9a9a9'
    darkkhaki: '#bdb76b'
    darkmagenta: '#8b008b'
    darkolivegreen: '#556b2f'
    darkorange: '#ff8c00'
    darkorchid: '#9932cc'
    darkred: '#8b0000'
    darksalmon: '#e9967a'
    darkseagreen: '#8fbc8f'
    darkslateblue: '#483d8b'
    darkslategray: '#2f4f4f'
    darkslategrey: '#2f4f4f'
    darkturquoise: '#00ced1'
    darkviolet: '#9400d3'
    deeppink: '#ff1493'
    deepskyblue: '#00bfff'
    dimgray: '#696969'
    dimgrey: '#696969'
    dodgerblue: '#1e90ff'
    firebrick: '#b22222'
    floralwhite: '#fffaf0'
    forestgreen: '#228b22'
    fuchsia: '#ff00ff'
    gainsboro: '#dcdcdc'
    ghostwhite: '#f8f8ff'
    gold: '#ffd700'
    goldenrod: '#daa520'
    gray: '#808080'
    green: '#008000'
    greenyellow: '#adff2f'
    grey: '#808080'
    honeydew: '#f0fff0'
    hotpink: '#ff69b4'
    indianred: '#cd5c5c'
    indigo: '#4b0082'
    ivory: '#fffff0'
    khaki: '#f0e68c'
    lavender: '#e6e6fa'
    lavenderblush: '#fff0f5'
    lawngreen: '#7cfc00'
    lemonchiffon: '#fffacd'
    lightblue: '#add8e6'
    lightcoral: '#f08080'
    lightcyan: '#e0ffff'
    lightgoldenrodyellow: '#fafad2'
    lightgray: '#d3d3d3'
    lightgreen: '#90ee90'
    lightgrey: '#d3d3d3'
    lightpink: '#ffb6c1'
    lightsalmon: '#ffa07a'
    lightseagreen: '#20b2aa'
    lightskyblue: '#87cefa'
    lightslategray: '#778899'
    lightslategrey: '#778899'
    lightsteelblue: '#b0c4de'
    lightyellow: '#ffffe0'
    lime: '#00ff00'
    limegreen: '#32cd32'
    linen: '#faf0e6'
    magenta: '#ff00ff'
    maroon: '#800000'
    mediumaquamarine: '#66cdaa'
    mediumblue: '#0000cd'
    mediumorchid: '#ba55d3'
    mediumpurple: '#9370db'
    mediumseagreen: '#3cb371'
    mediumslateblue: '#7b68ee'
    mediumspringgreen: '#00fa9a'
    mediumturquoise: '#48d1cc'
    mediumvioletred: '#c71585'
    midnightblue: '#191970'
    mintcream: '#f5fffa'
    mistyrose: '#ffe4e1'
    moccasin: '#ffe4b5'
    navajowhite: '#ffdead'
    navy: '#000080'
    oldlace: '#fdf5e6'
    olive: '#808000'
    olivedrab: '#6b8e23'
    orange: '#ffa500'
    orangered: '#ff4500'
    orchid: '#da70d6'
    palegoldenrod: '#eee8aa'
    palegreen: '#98fb98'
    paleturquoise: '#afeeee'
    palevioletred: '#db7093'
    papayawhip: '#ffefd5'
    peachpuff: '#ffdab9'
    peru: '#cd853f'
    pink: '#ffc0cb'
    plum: '#dda0dd'
    powderblue: '#b0e0e6'
    purple: '#800080'
    rebeccapurple: '#663399'
    red: '#ff0000'
    rosybrown: '#bc8f8f'
    royalblue: '#4169e1'
    saddlebrown: '#8b4513'
    salmon: '#fa8072'
    sandybrown: '#f4a460'
    seagreen: '#2e8b57'
    seashell: '#fff5ee'
    sienna: '#a0522d'
    silver: '#c0c0c0'
    skyblue: '#87ceeb'
    slateblue: '#6a5acd'
    slategray: '#708090'
    slategrey: '#708090'
    snow: '#fffafa'
    springgreen: '#00ff7f'
    steelblue: '#4682b4'
    tan: '#d2b48c'
    teal: '#008080'
    thistle: '#d8bfd8'
    tomato: '#ff6347'
    turquoise: '#40e0d0'
    violet: '#ee82ee'
    wheat: '#f5deb3'
    white: '#ffffff'
    whitesmoke: '#f5f5f5'
    yellow: '#ffff00'
    yellowgreen: '#9acd32'
