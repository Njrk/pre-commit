#!/bin/bash

gitleaksEnabled () {

  if [[ "$(git config hooks.gitleaks)" != "enable" ]]; then
      echo "gitleaks disable"
      exit 0
  fi
}

gitleaksInstall () {

  os=$(uname -s)
  arh=$(uname -m)
  gl_latest=$(curl -k -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
  gl_linkbase="https://github.com/gitleaks/gitleaks/releases/download"

  if [[ "$os" == "Linux" ]]; then
    if [[ "$arh" == "x86_64" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_x64.tar.gz
    elif [[ "$arh" == "i686" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_x32.tar.gz
    elif [[ "$arh" == "aarch64" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_arm64.tar.gz
    elif [[ "$arh" == "aarch64" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_arm64.tar.gz
    elif [[ "$arh" == "armv6l" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_armv6.tar.gz
    elif [[ "$arh" == "armv7l" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_linux_armv7.tar.gz
    else
      echo "Unsupported architecture: ${arh}"
      exit 1
    fi
  elif [[ "$os" == "Darwin" ]]; then
    if [[ "$arh" == "x86_64" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_darwin_x64.tar.gz
    elif [[ "$arh" == "aarch64" ]]; then
      gl_link=${gl_linkbase}/${gl_latest}/gitleaks_${gl_latest#v}_darwin_arm64.tar.gz
    else
      echo "Unsupported architecture: ${arh}"
      exit 1
    fi
  else
    echo "Unsupported OS: ${os}"
    exit 1
  fi

  curl -sSL -o gitleaks.tar.gz $gl_link
  tar -xzf gitleaks.tar.gz -C /usr/bin/ "gitleaks"
  rm gitleaks.tar.gz
  echo "gitleaks installed"
}

hooksInstall () {

  ls $PWD/.git/hooks &> /dev/null
    if [[ $? != 0 ]]; then
      echo "Run the script in your git repository. The script did not find the .git/hooks directory in the current path"
      exit 1
     else
      echo "pre-commit not found. Installation pre-commit."
      curl -sSL -o .git/hooks/pre-commit https://raw.githubusercontent.com/Njrk/pre-commit/main/pre-commit.sh
      chmod +x .git/hooks/pre-commit
      echo "pre-commit installed"
      echo "#################################"
      echo "To activate it, run the command: git config hooks.gitleaks enable"
      echo "#################################"
      exit 0
    fi

}

hooksStatus () {

    ls $PWD/.git/hooks/pre-commit &> /dev/null
      if [[ $? != 0 ]]; then
        hooksInstall
      fi
}

gitleaksStatus () {

  gitleaks -v &> /dev/null
    if [[ $? != 0 ]]; then
      echo "gitleaks not found. Installation gitleaks."
      echo "----------------------------------"
      gitleaksInstall
    fi
}

gitleaksChecks () {

  gitleaks detect --no-git -v --redact
    if [[ $? == 0 ]]; then
        echo "----------------------------------"
        echo "No secrets found. Commit allowed."
        echo "----------------------------------"
        exit 0
    else
        echo "----------------------------------"
        echo "Secrets found in the code. Commit rejected."
        echo "----------------------------------"
        exit 1
    fi
}

preChecks () {
  hooksStatus
  gitleaksEnabled
  gitleaksStatus
}

preChecks
gitleaksChecks
