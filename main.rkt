#lang racket

(require net/http-client)
(require net/uri-codec)
(require racket/string)
(require json)

(define (load-bearer-token path)
  (define in-port (open-input-file "/home/dougfort/.config/investigator/token"))
  (let ([line (read-line in-port)])
    (close-input-port in-port)
    (string-trim line)))

(define (prepare-query raw-query)
  (format "~a lang:en -is:retweet" raw-query))

(define (read-from-api bearer-token query)
  (define auth-header (format "Authorization: Bearer ~a" bearer-token))
  (define hc (http-conn-open "api.twitter.com"  #:ssl? #t))
  (http-conn-send! hc
                   (format "https://api.twitter.com/2/tweets/search/recent?query=~a" (uri-encode query))
                   #:headers (list auth-header))
  (let-values ([(status-line headers data-port) (http-conn-recv! hc)])
    (cond
      [(equal? status-line #"HTTP/1.1 200 OK")
       (read-json data-port)]
      [else (error "Invalid HTTP status: " status-line)])
    ))

(define (report-meta meta-ht)
  (printf "~v results ~v..~v~n"
          (hash-ref meta-ht 'result_count)
          (hash-ref meta-ht 'oldest_id)
          (hash-ref meta-ht 'newest_id)))

(define (report-data data)
  (for ([item data])
    (printf "~v: ~v~n" (hash-ref item 'id) (hash-ref item 'text))))

(module* main #f
  (print "query: ")
  (define raw-query (read-line))
  (define bearer-token (load-bearer-token "/home/dougfort/.config/investigator/token"))
  (define json-ht (read-from-api bearer-token (prepare-query raw-query)))
  ; we expect a hash table with these keys: '(data meta)
  (report-meta (hash-ref json-ht 'meta))
  (report-data (hash-ref json-ht 'data)))
