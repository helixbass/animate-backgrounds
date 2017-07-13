{ extend, Tween, Color } = $

is_string = (obj) ->
  'string' is $.type obj

# background-position logic and general approach from Extending jQuery

map = (arr, clb) ->
  clb elem, i for elem, i in arr
extended = (obj, objs...) ->
  extend {}, obj, objs...

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

  Tween.propHooks[hook_name ? prop_name] =
    get: parsed_tween
    set: (tween) ->
      init tween unless tween.set

      $ tween.elem
      .css prop_name,
        css_val_from_initialized_tween {tween, parsed_tween}

register_animation_handler
  prop_name: 'backgroundPosition'
  parse: (val) ->
    for bg in (val || '').split /\s*,\s*/
      dims = do ->
        unstandardizedDims = bg.split /\s+/

        if unstandardizedDims.length is 1
          unstandardizedDims =
            if unstandardizedDims[0] in ['top', 'bottom']
              [
                '50%'
                unstandardizedDims[0]
              ]
            else
              [
                unstandardizedDims[0]
                '50%'
              ]

        map(
          unstandardizedDims
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

    for endBg, bgIndex in parse end
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

        suppliedDims = bg.split /\s+/

        return suppliedDims unless suppliedDims.length is 1

        [
          suppliedDims[0]
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
    { start, end } = tween

    for endBg, bgIndex in parse end
      map endBg, ( val, i ) ->
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
      for bgStart, bgIndex in start
        bgEnd = end[bgIndex]

        _span = ( dim ) ->
          bgEnd[dim].amount - bgStart[dim].amount
        _adjusted = ( dim ) ->
          bgStart[dim].amount + pos * _span dim
        (
          for dim in [0, 1]
            bgStartDim = bgStart[dim]
            if bgStartDim?.unit
              "#{ _adjusted dim }#{ bgStartDim.unit }"
            else bgStartDim
        )
        .join ' '
        .trim()
    )
    .join ', '

# extend Tween.propHooks,
#   backgroundSize:
#     get: _get
#     set: _set
#   backgroundPosition:
#     get: _get
#     set: _set

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
      [0-9.] +
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
  return no for component, component_index in a._rgba when b._rgba[component_index] isnt component
  yes

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
    deg
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

gradient_handler = ({function_name, hook_name, parse_gradient, pre_stops_css}) -> {
  hook_name
  prop_name: 'backgroundImage'

  init_tween_end: ({tween, parse}) ->
    {start, end} = tween

    looks_like_shorthand = (end) ->
      return yes if ///
        \s *
        #{value_regex_chunk}
        \s *
        ->
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
          \[
          (\d +)
          \]
        ///.exec remaining
          [all, index] = match
          remaining = remaining[all.length..]

        match = ///
          ^
          \s *
          #{value_regex_chunk}
          \s *
          ->
          \s *
        ///.exec remaining
        [all, angle, first_direction, second_direction, position, unit, color] = match
        pair =
          if color?
            type: 'color'
            start: {color}
          else if angle or first_direction
            type: 'angle'
            start: angle: angle_from_direction {angle, first_direction, second_direction}
          else
            type: 'length'
            start: {unit, position: _int position}
        remaining = remaining[all.length..]
        match =
          ///
            ^
            #{value_regex_chunk}
            [^,\n\S] *
            ([,\n])
            \s *
          ///.exec remaining
        [all, angle, first_direction, second_direction, position, unit, color, separator] = match
        pair.end = # TODO: check that same type as start?
          if color?
            {color}
          else if angle or first_direction
            angle: angle_from_direction {angle, first_direction, second_direction}
          else
            {unit, position: _int position}
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
                continue unless color_eq color, stop.color
                extend (changed_stop ?= {}),
                  color: end_change.color
          ((changed ?= {}).stops ?= [])[stop_index] = changed_stop if changed_stop
        _change[image_index] = changed if changed
      _change # TODO: warn/error if no detected changes?

  parse: ( val ) ->
    _top_level_args = ( val ) ->
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
      parsed = parse_gradient {image, function_name}
      return parsed unless parsed?.stops_str
      {stops_str, obj} = parsed
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

      "#{function_name}(#{
        pre_stops_css {
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
  [all, angle, first_direction, second_direction, stops_str] = match

  {
    obj: angle: angle_from_direction {angle, first_direction, second_direction}
    stops_str
  }

pre_stops_css_linear_gradient = ({start_gradient, end_gradient, end_change, _change, pos, get_current_image}) ->
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
  }deg, "

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

  match = ///
    ^
    \s *
    #{function_name}\(
    \s *
    (?: # optional shape/extent/position
      (?:
        #{shape_regex_chunk}
        \s +
        #{extent_regex_chunk} ?
        |
        #{extent_regex_chunk}
        \s +
        #{shape_regex_chunk} ?
      )
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
  [all, shape1, extent1, extent2, shape2, stops_str] = match

  {
    obj:
      shape:
        shape1 ? shape2 ? 'ellipse'
      extent:
        extent1 ? extent2
    stops_str
  }

pre_stops_css_radial_gradient = ({start_gradient, end_gradient, end_change, pos}) ->
  {shape, extent} = start_gradient

  "#{shape}#{
    if extent
      " #{extent}"
    else ''
  }, "

register_animation_handler gradient_handler
  hook_name: 'radialGradient'
  function_name: 'radial-gradient'
  parse_gradient: parse_radial_gradient
  pre_stops_css: pre_stops_css_radial_gradient
