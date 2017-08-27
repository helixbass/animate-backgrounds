is_string = (obj) ->
  Object::toString.call(obj) is '[object String]'
is_array = (obj) ->
  Object::toString.call(obj) is '[object Array]'

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

    init = (tween) ->
      tween.start = parsed_tween tween

      tween.end = init_tween_end {tween, parse}

      tween.set = yes

      # console.log {tween}

    hook {
      prop_name, hook_name
      parse, parsed_tween
      init_tween_end, init
      css_val_from_initialized_tween
    }

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

  unit_regex_chunk = regex_chunk_str ///
    ( # unit
      %
      |
      \w +
    ) ?
  ///

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
      #{unit_regex_chunk}
    )
  ///

  relative_length_regex_chunk = regex_chunk_str ///
    (?:
      ( # relative
        [+-]
        =
      ) ?
      #{length_regex_chunk}
    )
  ///

  index_regex_chunk = regex_chunk_str ///
    (?:
      \[
      (\d +)
      \]
    )
  ///

  _extract_changes = ({parsed_end, start}) ->
    error "Animation end value '#{end}' has #{parsed_end.length} background images, but start value has #{start.length}" unless parsed_end.length is start.length

    _change = []
    for start_image, image_index in start
      end_image = parsed_end[image_index]
      changed = null

      for start_dim, dim_index in start_image
        end_dim = end_image[dim_index]
        continue unless start_dim.position? and end_dim.position?
        {position, unit} = start_dim
        continue unless position isnt end_dim.position
        (changed ?= [])[dim_index] = end_dim
      _change[image_index] = changed if changed
    _change

  normalize_rel_ops = ({parsed, start}) ->
    {
      start
      parsed_end:
        for end_image, image_index in parsed
          map end_image, (val, dim_index) ->
            return val unless val?.rel_op
            {rel_op, position} = val

            val.position =
              start[image_index][dim_index].position +
                position * if rel_op is '-=' then -1 else 1

            val
    }

  scaled = ({start, end, pos, prop}) ->
    if prop
      if is_string prop
        prop = do (prop) ->
          (val) -> val[prop]
      start = prop start
      end   = prop end
    val = start + pos * (end - start)
    val

  _looks_like_shorthand = (end) ->
    return yes if ///
      \s *
      #{length_regex_chunk}
      (?:
        \s +
        #{length_regex_chunk}
      ) ?
      \s *
      ->
      |
      #{index_regex_chunk}
    ///.exec end

  _parse_shorthand = ({start, end}) ->
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

        # TODO: match position keyword
        match = ///
          ^
          \s *
          #{length_regex_chunk}
          (?:
            [^\n\S] +
            #{length_regex_chunk}
          ) ?
          \s *
          ->
          \s *
        ///.exec remaining
        unless match
          # TODO: error unless index?
          match = ///
            ^
            \s *
            #{length_regex_chunk}
            [^\n\S] +
            #{length_regex_chunk}
            \s *
          ///.exec remaining

          [
            all
            position, unit='px'
            second_position, second_unit='px'
          ] = match
          (indexed_parsed_pairs[index] ?= [])
          .push
            start: 'any'
            end: {
              position, unit
              second_position, second_unit
            }
            type: 'full'
          remaining = remaining[all.length..]
          continue
        [
          all
          position, unit='px'
          second_position, second_unit='px'
        ] = match
        pair = {}
        set_from_match_params = (start_or_end) ->
          pair[start_or_end] =
            {unit, position: parseFloat position}
          if second_position
            pair.type = 'full' if start_or_end is 'start' # TODO: error if only start or end is a full stop?
            extend pair[start_or_end], {
              second_unit
              second_position: parseFloat second_position
            }
        set_from_match_params 'start'

        remaining = remaining[all.length..]
        # TODO: match position keyword
        match =
          ///
            ^
            #{length_regex_chunk}
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
          position, unit='px'
          second_position, second_unit='px'
          separator
        ] = match
        set_from_match_params 'end'
        (if index?
          indexed_parsed_pairs[index] ?= []
        else
          parsed_pairs
        ).push pair
        remaining = remaining[all.length..]

      extended indexed_parsed_pairs,
        all: parsed_pairs

    _change = []
    map start, (start_image, image_index) ->
      changing_vals_for_image =
        changing_vals.all[..]
        .concat(changing_vals[image_index] ? [])
      for {start: start_change, end: end_change, type} in changing_vals_for_image when type is 'full'
        [{position, unit}, {position: second_position, unit: second_unit}] = start_image
        continue unless (
          start_change is 'any' or
          position        is start_change.position and
          (unit           is start_change.unit or position is 0) and
          second_position is start_change.second_position and
          (second_unit    is start_change.second_unit or second_position is 0)
        )
        return _change[image_index] = [
          position: end_change.position
          unit:     end_change.unit
        ,
          position: end_change.second_position
          unit:     end_change.second_unit
        ]
      changed = null
      for {start: start_change, end: end_change, type} in changing_vals_for_image when type isnt 'full'
        for {position, unit}, dim_index in start_image
          continue unless start_change.position is position and start_change.unit is unit
          (changed ?= [])[dim_index] =
            position: end_change.position
            unit:     end_change.unit
      _change[image_index] = changed if changed?
    _change # TODO: warn/error if no detected changes? warn for each changing_val that wasn't found anywhere?

  _css_val = ({tween}) ->
    {pos, start, end} = tween

    dim_str = (dim) ->
      return dim unless dim.position?
      {position, unit} = dim
      "#{position}#{unit}"
    image_str = ([dim1, dim2]) ->
      "#{dim_str dim1} #{dim_str dim2}"

    (for start_image, image_index in start then do ->
      end_change = end[image_index]
      return image_str start_image unless end_change?

      (for dim, dim_index in start_image then do ->
        return dim_str dim unless dim_change=end_change?[dim_index]
        dim_str {
          position:
            scaled {
              start: dim
              end: dim_change
              pos
              prop: 'position'
            }
          unit: dim_change.unit
        }
      ).join ' '
      .trim()
    ).join ', '

  register_animation_handler
    prop_name: 'backgroundPosition'
    parse: (val) ->
      standardize_dims = (image) ->
        unstandardized_dims = image.split /\s+/

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

        presets =
          center: '50%'
          left:   '0%'
          right:  '100%'
          top:    '0%'
          bottom: '100%'

        map(
          unstandardized_dims
          (dim) ->
            "#{presets[dim] ? dim}"
        )

      for image in (val || '').split /\s*,\s*/
        # TODO: support edge offset syntax
        # TODO: error unless dims.length is 2
        for dim in standardize_dims image
          match =
            dim
            .match ///
              ^
              #{relative_length_regex_chunk}
              $
            ///
          # TODO: error unless match
          [all, rel_op, position, unit='px'] = match

          {
            rel_op, unit
            position: parseFloat position
          }

    init_tween_end: ({tween, parse}) ->
      {start, end} = tween

      return _parse_shorthand {start, end} if _looks_like_shorthand end

      parsed = parse end
      if parsed.length is 1 and parsed.length < start.length
        parsed =
          # repeat parsed[0], start.length
          for bg in start
            parsed[0]
      _extract_changes normalize_rel_ops {parsed, start}

    css_val_from_initialized_tween: _css_val

  register_animation_handler
    prop_name: 'backgroundSize'
    parse: (val) ->
      for image in (val || '').split /\s*,\s*/
        dims = do ->
          return [image, ''] if image in ['contain', 'cover']

          supplied_dims = image.split /\s+/

          return supplied_dims unless supplied_dims.length is 1

          [
            supplied_dims[0]
            'auto'
          ]

        for dim in dims then do ->
          match =
            dim
            .match ///
              ^
              (?:
                #{relative_length_regex_chunk}
                |
                auto
              )
              $
            ///
          return dim unless match?[2]
          [all, rel_op, position, unit='px'] = match

          {
            rel_op, unit
            position: parseFloat position
          }

    init_tween_end: ({tween, parse}) ->
      {start, end} = tween

      return _parse_shorthand {start, end} if _looks_like_shorthand end

      parsed = parse end
      if parsed.length is 1 and parsed.length < start.length
        parsed =
          # repeat parsed[0], start.length
          for image in start
            parsed[0]
      _extract_changes normalize_rel_ops {parsed, start}
    css_val_from_initialized_tween: _css_val

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

  angle_from_direction = ({angle, first_direction, second_direction}) ->
    return parseFloat angle if angle
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

      if match=///
        ^
        simultaneous
        \s *
      ///.exec end
        [all] = match
        start.simultaneous = yes
        end = end[all.length..]
      extract_changes = (parsed_end) ->
        error "Animation end value '#{end}' has #{parsed_end.length} background images, but start value has #{start.length}" unless parsed_end.length is start.length

        _change = []
        for start_image, image_index in start when not is_string start_image
          end_image = parsed_end[image_index]
          error "Expected gradient in animation end value but got '#{end_image}'" if is_string end_image
          error "Animation end value '#{end}' has #{end_image.stops.length} color stops, but start value has #{start_image.stops.length}" unless end_image.stops.length is start_image.stops.length
          changed = null

          compare_length_list = (prop_name) ->
            for start_dim, i in start_image[prop_name]
              end_dim = end_image[prop_name][i]
              continue unless start_dim.position isnt end_dim.position
              ((changed ?= {})[prop_name] ?= [])[i] = end_dim
          compare_length_list 'extent' if is_array start_image.extent
          if start_image.angle? and start_image.angle isnt end_image.angle
            (changed ?= {}).angle = end_image.angle
          compare_length_list 'position' if start_image.position?
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
                {unit, position: parseFloat position}
            if second_position
              pair.type = 'full_stop' if start_or_end is 'start' # TODO: error if only start or end is a full stop?
              extend pair[start_or_end],
                unit: second_unit
                position: parseFloat second_position
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
      for start_image, image_index in start
        changing_vals_for_image =
          changing_vals.all[..]
          .concat(changing_vals[image_index] ? [])
        continue if is_string start_image
        {stops, angle} = start_image
        changed = null
        detect_length_list_changes = (prop_name) ->
          return unless (start_prop=start_image[prop_name])?.length

          for {start: start_change, end: end_change, type} in changing_vals_for_image when type is 'length'
            for {position, unit}, pos_index in start_prop when start_change.position is position and start_change.unit is unit
              ((changed ?= {})[prop_name] ?= [])[pos_index] =
                position: end_change.position
                unit:     end_change.unit
        detect_length_list_changes 'extent'
        detect_length_list_changes 'position'
        if angle?
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
        {simultaneous} = start
        current ?=
          if simultaneous
            parsed_tween tween
          else
            start

      (for image, image_index in start then do ->
        return image if is_string image

        end_change = end[image_index]
        get_current_image = ->
          get_current()[image_index]
        current_image = do get_current_image
        # TODO: return (non-parsed) current image unless end_change?

        adjusted_stops = do ->
          return current_image.stops unless end_change?.stops
          for stop, stop_index in image.stops then do ->
            {color, unit, position} = stop

            current_stop = current_image.stops[stop_index]
            return current_stop unless stop_change=end_change.stops[stop_index]
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
            get_current_image
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
      (?:
        (closest-corner | closest-side | farthest-corner | farthest-side)
        |
        #{length_regex_chunk}
        (?:
          \s +
          #{length_regex_chunk}
        ) ?
      )
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
      (?: # optional shape/extent/position
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
      shape1, extent_keyword1, extent_first_position1, extent_first_unit1='px', extent_second_position1, extend_second_unit1='px'
      extent_keyword2, extent_first_position2, extent_first_unit2='px', extent_second_position2, extent_second_unit2='px', shape2
      keyword1, position1, unit1='px'
      keyword2, position2, unit2='px'
      stops_str
    ] = match

    {
      obj:
        shape:
          # TODO: error if explicitly "ellipse" but only one extent value?
          shape1 ? shape2 ? if (extent_first_position1? or extent_first_position2?) and not (extent_second_position1? or extent_second_position2?) then 'circle' else 'ellipse'
        extent: do ->
          return extent_keyword if extent_keyword=extent_keyword1 ? extent_keyword2
          if extent_first_position1?
            return [
              position: parseFloat extent_first_position1
              unit: extent_first_unit1
            ] unless extent_second_position1?
            return [
              position: parseFloat extent_first_position1
              unit: extent_first_unit1
            ,
              position: parseFloat extent_second_position1
              unit: extent_second_unit1
            ]
          return unless extent_first_position2?
          return [
            position: parseFloat extent_first_position2
            unit: extent_first_unit2
          ] unless extent_second_position2?
          [
            position: parseFloat extent_first_position2
            unit: extent_first_unit2
          ,
            position: parseFloat extent_second_position2
            unit: extent_second_unit2
          ]
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
              position: parseFloat(position1), unit: unit1
          second =
            if keyword2? or position2?
              if keyword2
                from_keyword keyword2
              else
                position: parseFloat(position2), unit: unit2
            else
              from_keyword 'center'

          if first_is_second
            [second, first]
          else
            [first, second]
      stops_str
    }

  pre_stops_css_radial_gradient = ({start_gradient, end_change, pos, get_current_image}) ->
    {shape} = start_gradient

    changed_length_list_str = (prop_name) ->
      return unless prop_change=end_change?[prop_name]

      (for start_dim, dim_index in start_gradient[prop_name]
        dim_change = prop_change[dim_index]
        "#{
          if dim_change
            scaled {
              start: start_dim.position
              end: dim_change.position
              pos
            }
          else
            get_current_image()[prop_name][dim_index]
            .position
        }#{ dim_change?.unit ? start_dim.unit }"
      ).join ' '
    length_list_str = (lengths) ->
      (for {position, unit} in lengths
        "#{position}#{unit}"
      ).join ' '

    "#{
      unless start_gradient.extent?.length # TODO: submit this as a Chrome bug?
        shape
      else ''
    }#{
      if changed_extent=changed_length_list_str 'extent'
        " #{changed_extent}"
      else
        if current_extent=get_current_image().extent
          " #{
            if is_array current_extent
              length_list_str current_extent
            else
              current_extent
          }"
        else ''
    } at #{
      if changed_position=changed_length_list_str 'position'
        changed_position
      else
        length_list_str get_current_image().position
    }, "

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
