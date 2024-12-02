let rec getListsFromStdin () =
  try
    let line = input_line stdin in
    let rest = getListsFromStdin () in
    match String.split_on_char '\t' line |> List.map int_of_string with
    | num1 :: num2 :: _ -> (num1, num2) :: rest
    | _ -> failwith "Invalid input"
  with End_of_file -> []

let sort_list_tuple (list1, list2) =
  (List.sort Int.compare list1, List.sort Int.compare list2)

let combine_list_tuple (list1, list2) = List.combine list1 list2
let sorted_lists = getListsFromStdin () |> List.split |> sort_list_tuple

let difference_score =
  sorted_lists |> combine_list_tuple
  |> List.map (fun (a, b) -> abs (a - b))
  |> List.fold_left ( + ) 0

let first_list = fst sorted_lists
let second_list = snd sorted_lists

let rec count_occurences item = function
  | hd :: tl -> if hd = item then 1 + count_occurences item tl else 0
  | _ -> 0

let rec chop_list n lst =
  if n <= 0 then lst
  else
    (* Format.printf "Chopping %n\n" n; *)
    match lst with
    | [] -> raise (Invalid_argument "List too short to chop")
    | hd :: tl -> chop_list (n - 1) tl

let rec chop_until predicate = function
  | hd :: tl when not (predicate hd) -> chop_until predicate tl
  | lst -> lst

let string_of_int_list lst =
  let rec make_str acc cv =
    match cv with
    | hd :: [] -> make_str (acc ^ Format.sprintf "%d" hd) []
    | hd :: tl -> make_str (acc ^ Format.sprintf "%d, " hd) tl
    | [] -> acc
  in
  "[" ^ make_str "" lst ^ "]"

let rec similarity_score acc = function
  | [], _ | _, [] -> acc
  | (hd :: tl as lst1), lst2 ->
      let occurences_l1 = count_occurences hd lst1 in
      let occurences_l2 = count_occurences hd lst2 in
      let chop_l1 = chop_list occurences_l1 lst1 in
      let chop_l2 =
        lst2 |> chop_list occurences_l2
        |> chop_until (fun num ->
               match tl with next :: _ -> num >= next | [] -> true)
      in
      Format.printf
        "hd: %d occ1: %2d occ2: %2d acc: %d l1: %s l2: %s chop1: %s chop2: %s \n"
        hd occurences_l1 occurences_l2 acc (string_of_int_list lst1)
        (string_of_int_list lst2)
        (string_of_int_list chop_l1)
        (string_of_int_list chop_l2);
      similarity_score
        (acc + (hd * occurences_l1 * occurences_l2))
        (chop_l1, chop_l2)

let _ =
  Format.printf "Difference score: %d\nSimilarity score: %d\n" difference_score
    (similarity_score 0 (first_list, second_list))
