;; we define the concatenation of two lists
;; using induction and dependent types.
#lang pie

;; we need the append defined previously
(require list-append)

;; helper: a special cons,
;; that appends at the end of a list: snoc
(claim snoc
	   (Pi ((E U))
		   (-> (List E) E
			   (List E))))
(define snoc
  (lambda (E)
	(lambda (start e)
	  (rec-List start
				(:: e nil)
				(step-append E)))))

;; the inductive step
(claim step-concat
	   (Pi ((E U))
		   (-> E (List E) (List E)
			   (List e))))
(define step-concat
  (lambda (E)
	(lambda (e es concat-es)
	  (snoc E concat-es e))))

;; actual concatenation
(claim concat
	   (Pi ((E U))
		   (-> (List E) (List E)
			   (List E))))
(define concat
  (lambda (E)
	(lambda (start end)
	  (rec-List end
				start
				step-concat E))))
