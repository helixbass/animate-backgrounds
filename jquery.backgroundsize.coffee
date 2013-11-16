{ extend, Tween } = $

_init = ( tween ) ->
  { elem, prop, end } = tween

  extend tween,
   start: _parse $( elem ).css prop
   end: _parse end
   set: yes

_parse = ( val ) ->
  (( arr ) ->
    arr[ 1 ] = parseFloat arr[ 1 ]
    arr
  ) arr for arr in ( dim
                      .match ///
                              ^
                              (
                               \d +
                              )
                              (
                               . *
                              )
                              $
                             /// for dim in val.split /\s+/ )

extend Tween.propHooks,
 backgroundSize:
  get: ( tween ) ->
    _parse $( tween.elem ).css tween.prop
  set: ( tween ) ->
    _init tween unless tween.set
    { elem,
      prop,
      pos,
      unit,
      start,
      end } = tween

    _span = ( axis ) ->
      end[ axis ][ 1 ] - start[ axis ][ 1 ]
    _adjusted = ( axis ) ->
      start[ axis ][ 1 ] + pos * _span axis
    $( elem )
     .css prop,
          ( "#{ _adjusted axis }#{ unit }" for axis in [ 0, 1 ] )
           .join ' '
