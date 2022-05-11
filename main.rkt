#lang racket/base

(require net/http-client)
(require racket/string)

(define (load-bearer-token path)
  (define in-port (open-input-file "/home/dougfort/.config/investigator/token"))
  (let ([line (read-line in-port)])
    (close-input-port in-port)
    (string-trim line)))

(define (read-from-api bearer-token)
  (define auth-header (format "Authorization: Bearer ~a" bearer-token))
  (define hc (http-conn-open "api.twitter.com"  #:ssl? #t))
  (http-conn-send! hc "https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev" #:headers (list auth-header))
  (call-with-values (λ () (http-conn-recv! hc)) (λ (status-line headers data-port) (println headers)))
  (http-conn-close! hc)) 

(module* main #f
  (define bearer-token (load-bearer-token "/home/dougfort/.config/investigator/token"))
  (read-from-api bearer-token))
