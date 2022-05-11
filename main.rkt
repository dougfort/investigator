#lang racket/base

(require net/http-client)
(require racket/string)

(define (load-bearer-token path)
  (define in-port (open-input-file "/home/dougfort/.config/investigator/token"))
  (let ([line (read-line in-port)])
    (close-input-port in-port)
    (string-trim line)))

(define (read-from-api bearer-token)
  (let ([auth-header (format "Authorization: Bearer ~a" bearer-token)])
    (http-sendrecv
     "api.twitter.com"
     "https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev"
     #:ssl? #t
     #:headers (list auth-header))))

(module* main #f
  (define bearer-token (load-bearer-token "/home/dougfort/.config/investigator/token"))
  (call-with-values (lambda () (read-from-api bearer-token)) (lambda (a b c) (println a))))
