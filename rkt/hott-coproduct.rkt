#lang pie

;; (claim recA+B-left
;;     (Pi ((A U) (B U) (C U))
;;         (-> (-> A C) (-> B C) (Either A B) C)))

;; (claim recA+B-right
;;     (Pi ((A U) (B U) (C U))
;;         (-> (-> A C) (-> B C) (Either A B) C)))

;; (define recA+B-left
;;   (lambda (A B C)
;;     (lambda (gl gr (left a))
;;       (gl a))))

;; (define recA+B-right
;;   (lambda (A B C)
;;     (lambda (gl gr (right b))
;;       (gr b))))

;; test

(claim either-test
       (-> Nat (Either Nat Nat)))
(define either-test
  (lambda (a)
    (right a)))
