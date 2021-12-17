#/bin/bash


if [[ `grep "jen_PWD" ~/.zshrc` ]];
then
  echo 'alias jen_PWD exist';
else
  echo 'alias jen_PWD not exist / alias jen_PWD will be inserted';
  echo "alias jen_PWD='kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo'" >> ~/.zshrc
fi
echo ''

if [[ `grep "argo_PWD" ~/.zshrc` ]];
then
  echo 'alias argo_PWD exist';
else
  echo 'alias argo_PWD not exist / alias argo_PWD will be inserted';
  echo "alias argo_PWD='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"|base64 -d'" >> ~/.zshrc
fi
echo 'Setting Alias for PWD Finished'
echo ''

echo 'source ~/.zshrc Finished! Check with jen_PWD & argo_PWD'
source ~/.zshrc
echo ''
