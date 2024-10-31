if [ ${SHOW_CONDA_STATUS:-0} -eq 1 ]; then
	__conda_setup="$(~/miniconda3/bin/conda 'shell.bash' 'hook' 2> /dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
				. ~/miniconda3/etc/profile.d/conda.sh
		else
				export PATH="~/miniconda3/bin:$PATH"
		fi
	fi
	unset __conda_setup
	conda deactivate

	if [ ! -f ~/.condarc ]; then
		echo "~/.condarc is missing, creating it now"
		touch ~/.condarc
	fi
	grep -i "changeps1:[[:space:]]?*false" ~/.condarc > /dev/null || conda config --set changeps1 False

	function get_conda_env {
		if [ ! -z "${CONDA_DEFAULT_ENV}" ]; then
			echo "Conda: ${CONDA_DEFAULT_ENV}"
		fi
	}
else
	function get_conda_env {
		echo -n
	}
fi

if [ ${SHOW_GIT_STATUS:-0} -eq 1 ]; then
	source ~/.dotfiles/scripts/git_prompt.sh
	export GIT_PS1_SHOWDIRTYSTATE=1
	export GIT_PS1_SHOWSTASHSTATE=1
	export GIT_PS1_SHOWUNTRACKEDFILES=1
	export GIT_PS1_SHOWUPSTREAM=auto

	function get_git_status {
		status=$(__git_ps1)
		if [ -n "${status}" ]; then
			echo "Git: ${status}" | xargs
		fi
	}
else
	function get_git_status {
		echo -n
	}
fi

function get_devtools_str {
	STATUS_STR=""
	git_status="$(get_git_status)"
	conda_env="$(get_conda_env)"
	if [ -n "${git_status}" ]; then
		STATUS_STR="${STATUS_STR}${git_status}"
	fi
	if [ -n "${conda_env}" ]; then
		if [ -n "${STATUS_STR}" ]; then
			STATUS_STR="${STATUS_STR} | "
		fi
		STATUS_STR="${STATUS_STR}${conda_env}"
	fi
	if [ -n "${STATUS_STR}" ]; then
		echo "${STATUS_STR}"
	fi
}
