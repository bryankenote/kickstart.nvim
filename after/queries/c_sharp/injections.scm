; (invocation_expression
;   function: (member_access_expression
; 	      expression: (identifier) @expression (#eq? @expression "Sql")
; 	      name: (identifier))
;   arguments: (argument_list
; 	       (argument
; 		 (interpolated_string_expression
; 		   (interpolated_verbatim_string_text) @injection.content
; 		   (#set! injection.include-children)
; 		   (#set! injection.language "sql")
; 		   ))))
;
; (invocation_expression
;   function: (member_access_expression
; 	      expression: (identifier)
; 	      name: (identifier) @name (#eq? @name "CommandFormat"))
;   arguments: (argument_list
; 	       (argument
; 		 (interpolated_string_expression
; 		   (interpolated_verbatim_string_text) @injection.content))))

(invocation_expression
  function: (member_access_expression
	      expression: (identifier) @expression (#eq? @expression "Sql")
	      name: (identifier))
  arguments: (argument_list
	       (argument
		 (string_literal
		   (string_literal_fragment) @injection.content
		   ; (#set! injection.include-children)
		   (#set! injection.language "sql")))))

(invocation_expression 
  function: (member_access_expression
	      expression: (identifier)
	      name: (identifier))
  arguments: (argument_list
	       (argument
		 (interpolated_string_expression
		   (interpolated_string_text) @injection.content
		   ; (#set! injection.include-children)
		   (#set! injection.language "sql")))))

(invocation_expression
  function: (member_access_expression
	      expression: (identifier)
	      name: (identifier) @name (#eq? @name "CommandFormat")) 
  arguments: (argument_list
	       (argument
		 (interpolated_string_expression
		   (interpolated_verbatim_string_text) @injection.content
		   ; (#set! injection.include-children)
		   (#set! injection.language "sql")))))
