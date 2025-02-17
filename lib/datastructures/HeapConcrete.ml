open Value 

module M : Heap.M with type vt = Value.t = struct
  
  type   t = ((int, Value.t array) Hashtbl.t * int)
  type  vt = Value.t (* indexes and sizes are always values *)

  let init () : t = (Hashtbl.create Parameters.size, 0)

  let malloc (h : t) (sz : vt) (pc : vt PathCondition.t) : (t * vt * vt PathCondition.t) list =
    let tbl, next = h in 
    match sz with
    | Integer i ->
        Hashtbl.replace tbl next (Array.make i (Integer 0));
        [(tbl, next+1), Loc next, pc ]
    | _ -> failwith ("InternalError: HeapConcrete.malloc, size must be an integer")
  
  let update (h : t) (arr : vt) (index : vt) (v : vt) (pc : vt PathCondition.t)  : (t * vt PathCondition.t) list =
    let tbl, _ = h in 
    match arr, index with 
    | Loc l, Integer i -> 
      (match Hashtbl.find_opt tbl l with 
      | Some arr -> 
          arr.(i) <- v; 
          [ h, pc ]
      | _ -> failwith ("InternalError: accessed array is not in the heap"))
    | _ -> failwith ("InternalError: HeapConcrete.update, arr must be location and index must be an integer")

  let lookup (h : t) (arr : vt) (index : vt) (pc : vt PathCondition.t) : (t * vt * vt PathCondition.t) list =
    ignore index;
    ignore arr;
    ignore pc;
    ignore h;
    let tbl, _ = h in 
    match arr, index with 
    | Loc l, Integer i -> 
      (match Hashtbl.find_opt tbl l with 
      | Some arr -> 
          if (Array.length arr <= i) 
            then failwith ("InternalError: accessing out-of-bounds index")
            else [ (h, arr.(i), pc) ]
      | _ -> failwith ("InternalError: accessed array is not in the heap"))
    | _ -> failwith ("InternalError: HeapConcrete.update, arr must be location and index must be an integer")

  let free (h : t) (arr : vt) (pc : vt PathCondition.t) : (t * vt PathCondition.t) list =
    let tbl, _ = h in 
    match arr with 
    | Loc l -> 
      (match Hashtbl.find_opt tbl l with 
      | Some _ -> 
         Hashtbl.remove tbl l; 
         [ h, pc ]
      | _ -> failwith ("InternalError: illegal free"))
    | _ -> failwith ("InternalError: HeapConcrete.update, arr must be location")
end

(*
type t = (int, int arry) Hashtbl.t

x := new (5); 
---- 
heap = { 1 -> { 0 -> 0, 1 -> 0, 2 -> 0, 3 -> 0, 4 -> 0} }
store = { x -> Loc 1 }
x[1] := 3; 
----
heap = { 1 -> { 0 -> 0, 1 -> 3, 2 -> 0, 3 -> 0, 4 -> 0} }
store = { x -> Loc 1 }
---
y := x[0]
---
heap = { 1 -> { 0 -> 0, 1 -> 3, 2 -> 0, 3 -> 0, 4 -> 0} }
store = { x -> Loc 1, y -> Int 0 }
*)