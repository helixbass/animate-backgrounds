{ extend, Tween, isArray } = $

# background-position logic and general approach from Extending jQuery

map = ( arr, clb ) ->
  clb elem, i for elem, i in arr

registerAnimationHandler = ({
  propName
  parse
  initTweenEnd
  cssValFromInitializedTween
}) ->
  parsedTween = ( tween ) ->
    parse $( tween.elem ).css propName

  init = ( tween ) ->
    tween.start = parsedTween tween

    tween.end = initTweenEnd { tween, parse }

    tween.set = yes
    # console.log { tween }

  Tween.propHooks[propName] =
    get: parsedTween
    set: ( tween ) ->
      init tween unless tween.set

      $ tween.elem
      .css propName,
        cssValFromInitializedTween tween

registerAnimationHandler
  propName: 'backgroundPosition'
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

        [
          _match[1]
          parseFloat _match[2]
          _match[3] or 'px'
        ]

  initTweenEnd: ({ tween, parse }) ->
    { start, end } = tween

    for endBg, bgIndex in parse end
      map endBg, ( val, i ) ->
        [rel_op, amount] = val
        return val unless rel_op

        val[1] =
          start[bgIndex][i][1] +
            amount * if rel_op is '-=' then -1 else 1

        val

  cssValFromInitializedTween: ( tween ) ->
    {
      pos
      start
      end
    } = tween

    (
      for bg, bgIndex in start
        bgStart = start[bgIndex]
        bgEnd   = end[  bgIndex]

        _span = ( dim ) ->
          bgEnd[dim][1] - bgStart[dim][1]
        _adjusted = ( dim ) ->
          bgStart[dim][1] + pos * _span dim
        ( "#{ _adjusted dim }#{ bgStart[dim][2] }" for dim in [0, 1])
        .join ' '
    )
    .join ', '

registerAnimationHandler
  propName: 'backgroundSize'
  parse: ( val ) ->
    for bg in (val || '').split /\s*,\s*/
      dims = do ->
        return [bg, ''] if bg in ['contain', 'cover']

        suppliedDims = bg.split /\s+/

        if suppliedDims.length is 1
          [
            suppliedDims[0]
            'auto'
          ]
        else
          suppliedDims

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
          [
            _match[1]
            parseFloat _match[2]
            _match[3] or 'px'
          ]

  initTweenEnd: ({ tween, parse }) ->
    { start, end } = tween

    for endBg, bgIndex in parse end
      map endBg, ( val, i ) ->
        return val unless isArray val
        [rel_op, amount] = val
        return val unless rel_op

        val[1] =
          start[bgIndex][i][1] +
            amount * if rel_op is '-=' then -1 else 1

        val

  cssValFromInitializedTween: ( tween ) ->
    {
      pos
      start
      end
    } = tween

    (
      for bg, bgIndex in start
        bgStart = start[bgIndex]
        bgEnd   = end[  bgIndex]

        _span = ( dim ) ->
          bgEnd[dim][1] - bgStart[dim][1]
        _adjusted = ( dim ) ->
          bgStart[dim][1] + pos * _span dim
        (
          for dim in [0, 1]
            bgStartDim = bgStart[dim]
            if isArray bgStartDim
              "#{ _adjusted dim }#{ bgStartDim[2] }"
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
