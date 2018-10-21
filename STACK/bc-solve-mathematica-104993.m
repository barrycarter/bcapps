card[HoldPattern[Union[a_,b_]]] = card[a] + card[b] - card[Intersection[a,b]]
card[HoldPattern[Subsets[a_]]] = 2^card[a]
card[a_List] := Length[a]




