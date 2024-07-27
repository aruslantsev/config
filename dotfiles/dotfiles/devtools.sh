if [ -f ~/.dotfiles/git_prompt.sh ]; then
	source ~/.dotfiles/git_prompt.sh
	export GIT_PS1_SHOWDIRTYSTATE=1
	export GIT_PS1_SHOWSTASHSTATE=1
	export GIT_PS1_SHOWUNTRACKEDFILES=1
	export GIT_PS1_SHOWUPSTREAM=auto
fi

if [ -f ~/.condarc ]; then
	grep -i "changeps1:[[:space:]]?*false" ~/.condarc > /dev/null || echo 'Run "echo changeps1: False > ~/.condarc" or "conda config --set changeps1 False"'
else
	echo "Error: ~/.condarc is missing"
fi

function get_git_status {
	if [ -f ~/.dotfiles/git_prompt.sh ]; then
		status=$(__git_ps1)
		if [ -n "${status}" ]; then
			echo "Git: ${status}" | xargs
		fi
	fi
}

function get_conda_env {
	if [ ! -z "${CONDA_DEFAULT_ENV}" ]; then
		echo "Conda: ${CONDA_DEFAULT_ENV}"
	fi
}

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
