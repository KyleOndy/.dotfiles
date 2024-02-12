(ns foundry
  (comment
    `foo
    (str (java.time.LocalDate/of 2019 12 18))
    (str (java.time.LocalDate/now))
    (java.time.LocalDate/now)
    ; date formats:
    ; https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html
    (.format (java.time.LocalDate/now)
             (java.time.format.DateTimeFormatter/ofPattern "yyyy-MM-dd"))
    (.format (java.time.LocalDate/now)
             (java.time.format.DateTimeFormatter/ofPattern "w"))
    (.format (java.time.LocalDate/now)
             (java.time.format.DateTimeFormatter/ofPattern "q"))
    (week-of-date java.time.LocalDate/now))
  (defn week-of-date
    [date]
    ((str (.format date (java.time.format.DateTimeFormatter/ofPattern "w"))))))
