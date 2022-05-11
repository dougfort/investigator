#lang racket/base

(require net/http-client)
(require racket/string)
(require racket/port)

(define (load-bearer-token path)
  (define in-port (open-input-file "/home/dougfort/.config/investigator/token"))
  (let ([line (read-line in-port)])
    (close-input-port in-port)
    (string-trim line)))

(define (read-from-api bearer-token)
  (define auth-header (format "Authorization: Bearer ~a" bearer-token))
  (define hc (http-conn-open "api.twitter.com"  #:ssl? #t))
  (http-conn-send! hc "https://api.twitter.com/2/tweets/search/recent?query=from:twitterdev" #:headers (list auth-header))
  (let-values ([(status-line headers data-port) (http-conn-recv! hc)])
    (cond
      [(equal? status-line #"HTTP/1.1 200 OK")
       (port->bytes data-port #:close? #t)]
      [else (error "Invalid HTTP status: " status-line)])
    )) 

(module* main #f
  (define bearer-token (load-bearer-token "/home/dougfort/.config/investigator/token"))
  (read-from-api bearer-token))
