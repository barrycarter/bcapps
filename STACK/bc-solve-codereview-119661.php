<?

function calculateWeightedAverage($ratings)
{
  $values = array_values($ratings);
  sort($values);

  $count = count($values);
  $weights = array_fill(0, $count, 1);

  $out = (int) ($count / 3);
  $out2 = pow($out + 1, 2);

  $max = $count - 1;
  $min = 0;

  for ($i = 0; $i < $out; $i++) {
    $j = $i + 1;
    $weights[$min + $i] = $j * $j / $out2;
    $weights[$max - $i] = $j * $j / $out2;
  }

  $sum = array_sum($weights);

  for ($i = 0; $i < $count; $i++) {
    $weights[$i] /= $sum;
  }

  $rating = 0;
  for ($i = 0; $i < $count; $i++) {
    $rating += $values[$i] * $weights[$i];
  }

  return $rating;
}

echo calculateweightedAverage(array(1,2,3,4));
echo "\n";

?>
