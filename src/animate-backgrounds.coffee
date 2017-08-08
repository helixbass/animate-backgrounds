is_string = (obj) ->
  Object::toString.call(obj) is '[object String]'

# background-position logic and general approach from Extending jQuery

map = (arr, clb) ->
  clb elem, i for elem, i in arr
extend = (obj, objs...) ->
  for _obj in objs
    for key, val of _obj
      obj[key] = val
  obj
extended = (obj, objs...) ->
  extend {}, obj, objs...

export default ({hook, Color}) ->
  register_animation_handler = ({
    prop_name, hook_name
    parse
    init_tween_end
    css_val_from_initialized_tween
  }) ->
    parsed_tween = (tween) ->
      parse window.getComputedStyle(tween.elem)[prop_name]

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

  error = (msg) ->
    throw new SyntaxError msg

  gradient_handler = ({function_name, hook_name, parse_gradient, detect_gradient_type, pre_stops_css}) -> {
    hook_name
    prop_name: 'backgroundImage'

    init_tween_end: ({tween, parse}) ->
      {start, end} = tween

      extract_changes = (parsed_end) ->
        error "Animation end value '#{end}' has #{parsed_end.length} background images, but start value has #{start.length}" unless parsed_end.length is start.length

        _change = []
        for start_image, image_index in start when not is_string start_image
          end_image = parsed_end[image_index]
          error "Expected gradient in animation end value but got '#{end_image}'" if is_string end_image
          error "Animation end value '#{end}' has #{end_image.stops.length} color stops, but start value has #{start_image.stops.length}" unless end_image.stops.length is start_image.stops.length
          changed = null

          if start_image.angle? and start_image.angle isnt end_image.angle
            (changed ?= {}).angle = end_image.angle
          if start_image.position?
            for start_pos, i in start_image.position
              end_pos = end_image.position[i]
              continue unless start_pos.position isnt end_pos.position
              ((changed ?= {}).position ?= [])[i] = end_pos
          for start_stop, stop_index in start_image.stops
            end_stop = end_image.stops[stop_index]
            changed_stop = null
            change_stop = (prop_name) ->
              extend (changed_stop ?= {}),
                "#{prop_name}": end_stop[prop_name]
            change_stop 'position' if start_stop.position isnt end_stop.position
            change_stop 'unit'     if start_stop.unit     isnt end_stop.unit
            change_stop 'color'    unless Color.eq start_stop.color, end_stop.color
            ((changed ?= {}).stops ?= [])[stop_index] = changed_stop if changed_stop
          _change[image_index] = changed if changed
        _change

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
      return extract_changes parse end unless looks_like_shorthand end

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
                continue unless _eq=Color.eq color, stop.color
                color_change = Color.create end_change.color
                if use_opacity=_eq?.opacity
                  color_change = Color.setAlpha color_change, use_opacity
                extend (changed_stop ?= {}),
                  color: color_change
              when 'full_stop'
                {position, unit, color} = start_change
                continue unless position is stop.position and unit is stop.unit and _eq=Color.eq color, stop.color
                color_change = Color.create end_change.color
                if use_opacity=_eq?.opacity
                  color_change = Color.setAlpha color_change, use_opacity
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
                      # when 0
                      #   0
                      when split_stops.length - 1
                        100
                      else
                        0
                  unit = '%'

                color:
                  Color.create color
                position:
                  parseFloat position if position?
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
      current = null
      get_current = ->
        current ?= parsed_tween tween

      (for image, image_index in start then do ->
        return image if is_string image

        end_change = end[image_index]
        current_image = get_current()[image_index]

        adjusted_stops =
          for stop, stop_index in image.stops then do ->
            {color, unit, position} = stop

            current_stop = current_image.stops[stop_index]
            return current_stop unless stop_change=end_change?.stops?[stop_index]
            {
              color:
                if color_change=stop_change.color
                  Color.transition {
                    start: color
                    end: color_change
                    pos
                  }
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

        "#{image.function_name ? function_name}(#{
          (image.pre_stops_css ? pre_stops_css) {
            start_gradient: image
            end_change
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

  pre_stops_css_linear_gradient = ({start_gradient, end_change, pos, get_current_image}) ->
    {angle_unit} = start_gradient

    "#{
      if angle_change=end_change?.angle
        scaled {
          start: start_gradient.angle
          end: angle_change
          pos
        }
      else
        get_current_image()
        .angle
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

  pre_stops_css_radial_gradient = ({start_gradient}) ->
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
