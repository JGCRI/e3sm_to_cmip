#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:
  # generate segments
  frequency: int

  # discover_atm_files
  atm_data_path: string
  start_year: int
  end_year: int

  num_workers: int
  casename: string

  # hrzremap
  std_var_list: string[]
  hrz_atm_map_path: string

  # cmor
  tables_path: string
  metadata_path: string
  scripts_path: string
  cmor_var_list: string[]
  logdir: string

outputs:
  cmorized:
    type: 
      Directory[]
    outputSource: step_run_segment/cmorized

steps:

  step_segments:
    run: generate_segments.cwl
    in:
      start: start_year
      end: end_year
      frequency: frequency
    out:
      - segments_start
      - segments_end
  
  step_setup_input_files:
    run:
      atm-std-setup-input-files.cwl
    scatter:
      - start_year
      - end_year
    scatterMethod: dotproduct
    in:
      atm_data_path: atm_data_path
      start_year: step_segments/segments_start
      end_year: step_segments/segments_end
      num_workers: num_workers
      casename: casename
      std_var_list: std_var_list
      year_per_file: frequency
      hrz_atm_map_path: hrz_atm_map_path
      tables_path: tables_path
      metadata_path: metadata_path
      cmor_var_list: cmor_var_list
      logdir: logdir
    out:
      - cwl_input_files
  
  step_run_segment:
    run:
      class: CommandLineTool
      baseCommand: [cwltool, --parallel, --no-compute-checksum]
      inputs:
        cwl_input:
          type: File
        scripts_path:
          type: string
      outputs:
        cmorized:
          type: Directory
          outputBinding:
            glob: CMIP6
      arguments:
        - $(inputs.scripts_path + "/atm-std-single-segment.cwl")
        - $(inputs.cwl_input.path)
    in:
      cwl_input: step_setup_input_files/cwl_input_files
      scripts_path: scripts_path
    out:
      - cmorized
    scatter:
      - cwl_input
