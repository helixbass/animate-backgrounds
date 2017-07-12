{ extend, Tween, type, Color } = $

# background-position logic and general approach from Extending jQuery

map = ( arr, clb ) ->
  clb elem, i for elem, i in arr

registerAnimationHandler = ({
  prop_name, hook_name
  parse
  init_tween_end
  css_val_from_initialized_tween
}) ->
  parsedTween = ( tween ) ->
    parse $( tween.elem ).css prop_name

  init = ( tween ) ->
    tween.start = parsedTween tween

    tween.end = init_tween_end { tween, parse }

    tween.set = yes
    console.log { tween }

  Tween.propHooks[hook_name ? prop_name] =
    get: parsedTween
    set: ( tween ) ->
      init tween unless tween.set

      $ tween.elem
      .css prop_name,
        css_val_from_initialized_tween tween

registerAnimationHandler
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

registerAnimationHandler
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

_int = ( str ) ->
  parseInt str, 10

registerAnimationHandler
  hook_name: 'linearGradient'
  prop_name: 'backgroundImage'

  init_tween_end: ({ tween, parse }) ->
    { start, end } = tween

    parse end

   # unit: if end.indexOf '%' > -1
   #           '%'
   #       else
   #           'px'

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
      match = ///
        ^
        \s *
        linear-gradient\(
        \s *
        ( # angle
          - ?
          \d +
        )
        deg
        \s *
        ,
        \s *
        ( # stops
          (?:
            (?:
              rgb\(
              [^)] *
              \)
            )
            |
            [^)] +
          ) *
        )
        \)
        \s *
        $
      ///.exec image
      return image unless match
      [all, angle, stops] = match

      angle:
        _int angle
      stops:
        for stop in _top_level_args stops
          match = ///
            ^
            \s *
            ( # color
              (?: # rgb
                rgb\(
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
            ) ?
          ///.exec stop
          [all, color, position, unit] = match

          color:
            Color color
          position:
            _int(position ? 0)
          unit:
            unit ? 'px'

  css_val_from_initialized_tween: ( tween ) ->
    { pos, start, end } = tween

    (for image, image_index in start then do ->
      return image if 'string' is type image
      end_image = end[image_index]

      _scaled = (_prop) ->
        # _prop = if 'string' is type prop
        #             ( val ) -> val[ prop ]
        #         else
        #             prop
        start_val = _prop image
        start_val + pos * (_prop(end_image) - start_val)

      adjusted_stops =
        for {color, unit}, i in image.stops then {
          color:
            color.transition end[image_index].stops[i].color, pos
          position:
            _scaled ({stops}) -> stops[i].position
          unit
        }

      "linear-gradient(#{_scaled ({angle}) -> angle}deg, #{
        ("#{color} #{position}#{unit}" for {color, position, unit} in adjusted_stops)
        .join ', '
      })"
    )
    .join ', '
