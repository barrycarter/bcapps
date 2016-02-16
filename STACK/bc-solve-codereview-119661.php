<?

// It sorts them and then applies a weight to the upper third (count /
// 3) and lower third items in the array, giving majority weight to
// values in the middle. For instance, if the votes were [1, 4, 7],
// the weight of the 1 and 7 would be decreased before calculating the
// average. If it were [2, 2, 3, 4, 4, 7] the weights of the 2, 2,
// second 4, and 7 would be lowered. - user1960364 Feb 11 at 22:14

protected function calculateWeightedAverage($ratings)
{
  $sum = 0;
  $rating = 0;

  $values = array_values($ratings);
  sort($values);

  $count = count($values);
  $out = (int) ($count / 3);
  $out2 = pow($out + 1, 2);

  for ($i=0; $i<$count; $i++) {
    if ($i < $out) {
      $weights[$i] = pow(($i+1),2)/$out2;
    } elseif ($i > $count-$out-1) {
      $weights[$i] = pow($count-$i,2)/$out2;
    } else {
      $weights[$i] = 1;
    }
    $sum += $weights[$i];
  }

  for ($i = 0; $i < $count; $i++) {
    $rating += $values[$i] * $weights[$i]/$sum;
  }

  return $rating;
}

echo calculateweightedAverage(array(1,2,3,4,5,6,4,2,1));
echo "\n";

?>
