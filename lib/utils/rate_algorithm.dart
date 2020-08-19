double rateAlgorithm(int total) {
  double reviews = 0.0;

  if (total >= 1 && total <= 10) {
    reviews = total / 2;
    return reviews;
  }

  if (total > 10 && total <= 100) {
    reviews = total / 20;
     return reviews;
  }

  if (total > 100 && total <= 1000) {
    reviews = total / 200;
     return reviews;
  }

  if (total > 1000 && total <= 10000) {
    reviews = total / 2000;
     return reviews;
  }

  if (total > 10000 && total <= 100000) {
    reviews = total / 20000;
     return reviews;
  }

  if (total > 100000 && total <= 1000000) {
    reviews = total / 200000;
     return reviews;
  }

  if (total > 1000000 && total <= 10000000) {
    reviews = total / 2000000;
     return reviews;
  }

  if (total > 10000000 && total <= 100000000) {
    reviews = total / 20000000;
     return reviews;
  }
  if (total > 100000000 && total <= 1000000000) {
    reviews = total / 200000000;
     return reviews;
  }
  if (total > 1000000000 && total <= 10000000000) {
    reviews = total / 2000000000;
     return reviews;
  }
}
