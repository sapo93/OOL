;;; Surname Name ID


;;;; Hash Table Used To Store Classes Informations
(defparameter *classes-specs* (make-hash-table))



;;;; Function Used To Insert The class-spec To The  Hash Table
(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))



;;;; Function That Recovers The class-spec From The Hash Table
;;;; Uses The Function: gethash key hashtable
;;;; Wich Finds The Object In hashtable With key As Key
;;;; If Key Not Found, Returns nil
(defun get-class-spec (name)
  (gethash name *classes-specs*))



;;;; Method-Process
;;;; Function Used To Process Methods, Rewriting Them To
;;;; Lisp Functions 
(defun method-process (method-name method-spec)
  (setf (fdefinition method-name) (lambda (first method-spec) (second method-spec)))
  (eval (rewrite-method-code method-name  method-spec)))
	
	

;;;; Input Checking For The Slots
(defun check-slot (slot-values)
  (if (null slot-values) ;; slot-values Is Empty, Return True
      T
      (if (symbolp (first slot-values)) ;; The First Element Must Be A Symbol
	  (if (equal (car (second slot-values)) (quote method))
	      (and (method-process (first slot-values) (second slot-values))
		   (check-slot (rest (rest slot-values))))
	      (check-slot (rest (rest slot-values)))) ;; Check From Third Element
	  Nil)))



;;;; Input Checking For The Class
(defun input-class-check (name parent slot-values)
  (if (symbolp name) ;; Name Must Be A Symbol
      (if (symbolp parent) ;; Parent Must Be A Symbol
	  (if (not (atom slot-values)) ;; Slot Values Must Be A List
	      (check-slot slot-values)
	      Nil)
	  Nil)
      Nil))



;;;; Define-Class
;;;; Function Used To Define A New Class
(defun define-class (class-name parent &rest slot-values)
  (if (input-class-check class-name parent slot-values)  
      (if (not (get-class-spec class-name)) ;; Check If Class Is Already Defined
	  (if (null parent) ;; Parent Class If Exists Must Be Defined
	      (add-class-spec class-name (append (list parent) slot-values))
	      (if (not (null (get-class-spec parent)))
		  (add-class-spec class-name (append (list parent) slot-values))
		  (error "Parent Class Not Defined !!!")))
	(error "Class Already Defined !!!"))
      (error "Wrong Input!!!")))
	


;;;; New 
;;;; Instantiate A New Class Previously Defined
(defun new (class-name &rest slot-values)
  (if (symbolp class-name) 
      (if (get-class-spec class-name)
	  (if (check-slot slot-values)
	      (append (list class-name) slot-values)
	      (error "Wrong Slot Values"))
	  (error "Class Not Defined !!!"))
      (error "Wrong Class Name")))
      



;;;; Find Slot
;;;; This Function Find The Slot-Name In The
;;;; List. Nil If Not Found
(defun find-slot (list slot-name)
  (if (not (null list)) ;; Instance Mustn't Be Nil
      (if (equal (first list) slot-name) ;; Slot Found
	  (second list) ;; Return Slot-Value
	  (find-slot (rest (rest list)) slot-name)) ;; Recursive Step
      Nil))
      



;;;; Find Slot Parent
;;;; This Function Find The Slot-Name Recursively
;;;; In The Parents. Nil If Not Found
(defun find-slot-p (parent slot-name)
  (if (not (null parent)) ;; Parent  Mustn't Be Nil
      (if (not (null (get-class-spec parent)))
	  (if (not (null (find-slot (get-class-spec parent) slot-name)))
	      (find-slot (get-class-spec parent) slot-name)
	      (find-slot-p (first (get-class-spec parent)) slot-name))
	  Nil)
      Nil))
      




;;;; Get Slot
(defun get-slot (instance slot-name)
  (if (and (not (null instance)) (symbolp slot-name))
      (if (not (null (find-slot (rest instance) slot-name))) 
	  (find-slot (rest instance) slot-name)
	  (let ((class-sp (get-class-spec (first instance))))
	    (if (not (null class-sp))
		(if (not (null (find-slot (rest class-sp) slot-name)))
		    (find-slot (rest class-sp) slot-name)
		    (if (not (null (find-slot-p (first class-sp) slot-name)))
			(find-slot-p (first class-sp) slot-name)
			(error "Slot Not Found")))
		(error "Slot Not Found"))))
      (error "Wrong Input")))



 
		  
