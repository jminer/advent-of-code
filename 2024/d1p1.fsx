
// Part 1 took me 1:40 - 2:39

open System.IO

let lines = File.ReadAllLines "d1_input"

let parse_locations (lines: string array) =
    let line_ids =
        lines |> Seq.map (fun line ->
        if line.Length = 0 then
            None
        else Some(line.Split("   ") |> Seq.ofArray |> Seq.map System.Int32.Parse))
        |> Seq.choose id
    let lists =
        line_ids |> Seq.transpose
    lists

let calc_distance (lists: int seq seq) =
    let pairs =
        lists |> Seq.map Seq.sort
        |> Seq.toArray
    let distances =
        Seq.zip pairs[0] pairs[1]
        |> Seq.map (fun (n, m) -> System.Math.Abs (n - m))
    let distance =
        distances |> Seq.fold (fun state dist -> state + dist) 0
    distance

printfn "%A" ((parse_locations lines) |> calc_distance)
