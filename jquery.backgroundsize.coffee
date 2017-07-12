{ extend, Tween, type, Color } = $

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
  parsed_tween = ( tween ) ->
    parse $( tween.elem ).css prop_name

  init = ( tween ) ->
    tween.start = parsed_tween tween

    tween.end = init_tween_end { tween, parse }

    tween.set = yes

    console.log {tween}

  Tween.propHooks[hook_name ? prop_name] =
    get: parsed_tween
    set: ( tween ) ->
      init tween unless tween.set

      $ tween.elem
      .css prop_name,
        css_val_from_initialized_tween tween

register_animation_handler
  prop_name: 'backgroundPosition'
  parse: ( val ) ->
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

  init_tween_end: ({ tween, parse }) ->
    { start, end } = tween

    for endBg, bgIndex in parse end
      map endBg, ( val, i ) ->
        {rel_op, amount} = val
        return val unless rel_op

        val.amount =
          start[bgIndex][i].amount +
            amount * if rel_op is '-=' then -1 else 1

        val

  css_val_from_initialized_tween: ( tween ) ->
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
  parse: ( val ) ->
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

  init_tween_end: ({ tween, parse }) ->
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

  css_val_from_initialized_tween: ( tween ) ->
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
    \s +
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

scaled = ({start, end, pos, prop}) ->
  if prop
    if 'string' is type prop
      prop = do (prop) ->
        (val) -> val[prop]
    start = prop start
    end   = prop end
  val = start + pos * (end - start)
  val

gradient_handler = ({function_name, hook_name, parse_gradient, pre_stops_css}) -> {
  hook_name
  prop_name: 'backgroundImage'

  init_tween_end: ({ tween, parse }) ->
    { start, end } = tween

    parse end # TODO: error if end doesn't match start eg wrong # of background images/stops

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
                #{length_regex_chunk} ?
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

  css_val_from_initialized_tween: ( tween ) ->
    { pos, start, end } = tween

    (for image, image_index in start then do ->
      return image if 'string' is type image
      end_image = end[image_index]

      _scaled = (prop) ->
        scaled {
          start: image
          end: end_image
          pos, prop
        }

      adjusted_stops =
        for {color, unit}, i in image.stops then {
          color:
            color.transition end[image_index].stops[i].color, pos
          position:
            _scaled ({stops}) -> stops[i].position
          unit
        }

      "#{function_name}(#{
        pre_stops_css {
          start_gradient: image
          end_gradient: end_image
          pos
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
      (?: # angle or directions
        ( # angle
          - ?
          \d +
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
    obj:
      angle: do ->
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
    stops_str
  }

pre_stops_css_linear_gradient = ({start_gradient, end_gradient, pos}) ->
  "#{
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
  match = ///
    ^
    \s *
    #{function_name}\(
    \s *
    (?: # optional shape/extent/position
      (circle | ellipse)
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
  [all, shape, stops_str] = match

  {
    obj: {shape}
    stops_str
  }

pre_stops_css_radial_gradient = ({start_gradient, end_gradient, pos}) ->
  {shape} = start_gradient

  "#{shape}, "

register_animation_handler gradient_handler
  hook_name: 'radialGradient'
  function_name: 'radial-gradient'
  parse_gradient: parse_radial_gradient
  pre_stops_css: pre_stops_css_radial_gradient
