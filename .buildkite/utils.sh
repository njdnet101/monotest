run_command_for () {

  run_folder=""

  case "${2}" in

    "Proj1") run_folder="proj1"
    ;;
    "Proj2") run_folder="proj2"
    ;;

    *) run_folder=""
    ;;
  esac

  if [[ ! -z  "${run_folder}" ]]; then
    cmd_file="$(pwd)/${run_folder}/.buildkite/hooks/${1}-command"
    [[ -e "${cmd_file}" ]] && echo "Running ${1}-command hook in ${run_folder} folder" && echo $cmd_file | sh
  fi
}

run_pre_command_for () {
  run_command_for "pre" "${1}"
}

run_post_command_for () {
  run_command_for "post" "${1}"
}
