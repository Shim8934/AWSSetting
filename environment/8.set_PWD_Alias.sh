#/bin/bash


if [[ `grep "jen_PWD" ~/.bashrc` ]];
then
  echo 'alias jen_PWD exist';
else
  echo 'alias jen_PWD not exist / alias jen_PWD will be inserted';
  echo "alias jen_PWD='kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo'" >> ~/.bashrc
fi
echo ''

if [[ `grep "argo_PWD" ~/.bashrc` ]];
then
  echo 'alias argo_PWD exist';
else
  echo 'alias argo_PWD not exist / alias argo_PWD will be inserted';
  echo "alias argo_PWD='kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"|base64 -d'" >> ~/.bashrc
fi
echo 'Setting Alias for PWD Finished'
echo ''

echo 'source ~/.bashrc Finished! Check with jen_PWD & argo_PWD'
source ~/.bashrc
echo ''
