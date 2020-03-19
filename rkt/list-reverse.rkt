;; we define reversing a list using induction
;; and dependent types.
#lang pie

;; we need snoc
(require list-append)

;; reversing a list
(claim reverse
	   (Pi ((E U))
		   (-> (List E)
			   (List E))))

;; the inductive step
(claim step-reverse
	   (Pi ((E U))
		   (-> E (List E) (List E)
			   (List E))))

(define step-reverse
  (lambda (E)
	(lambda (e es reverse-es)
	  (snoc E reverse-es e))))

(define reverse
  (lambda (E)
	(lambda (es)
	  (rec-List es
				(the (List E) nil)      ; nil
				(step-Reverse E)))))
