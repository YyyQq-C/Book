* jprofiler添加监听  
`-agentpath:/opt/jprofiler/jprofiler9/bin/linux-x64/libjprofilerti.so=port=31757,nowait`
* java添加远程调试端口  
`-XX:+AggressiveOpts -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=[port]`
