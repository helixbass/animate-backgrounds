import anime from 'animejs'
import animation_hook from './animate-backgrounds'

animation_hook ({
  hook_name, prop_name
  css_val_from_initialized_tween
  parsed_tween, parse
  init_tween_end
}) ->
  anime.cssHooks[hook_name ? prop_name] =
    get: ({to, from, eased, el}) ->
      css_val_from_initialized_tween {
        tween:
          start: from
          end: to
          pos: eased
          elem: el
        parsed_tween
      }
    parse: ({cssValue}) ->
      parse cssValue
    parseTo: ({to, from}) ->
      init_tween_end {
        tween:
          start: from
          end: to
        parse
      }
