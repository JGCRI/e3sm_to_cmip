#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: [srun]
requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.checker)

inputs:
  file_list: string[]
  md5_path: File
  checker: File
arguments:
  - "python"
  - $(inputs.checker.path)
  - "--write-to-file"
  - "--md5-path"
  - $(inputs.md5_path.path)
  - "--file-list"
  - $(inputs.file_list)
outputs:
  hash_status:
    type: File
    outputBinding:
      glob: hash_*