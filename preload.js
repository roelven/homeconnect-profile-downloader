const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  sendFormData: (data) => {
    ipcRenderer.send('form-submitted', data);
  },
  getZipFiles: () => ipcRenderer.invoke('get-zip-files'),
  getProfilePath: () => ipcRenderer.invoke('get-profile-path'),
});
