import $ from 'jquery'
import animation_hook from './animate-backgrounds'

animation_hook ({
  hook_name, prop_name
  css_val_from_initialized_tween
  parsed_tween, parse
  init_tween_end, init
}) ->
  Tween.propHooks[hook_name ? prop_name] =
    get: parsed_tween
    set: (tween) ->
      init tween unless tween.set

      $ tween.elem
      .css prop_name,
        css_val_from_initialized_tween {tween, parsed_tween}
