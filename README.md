# POC Redis and Tomcat - Issue with Spring Security and the Kryo Codec 

A issue was identified with a Spring MVC application deployed on Tomcat 9.0.84.
This repository is a docker compose POC to reproduce the issue. It uses a trivial Spring MVC app, Redis, Tomcat with Redisson, and Nginx for load balancing. The Nginx container is configured to send requests to random upstream tomcat instances (2 available). The stack trace of the exception is found at the end of this README.

**THIS CODE IS NOT INTENDED FOR PRODUCTION USAGE AND IT DOESN'T REPRESENT ANY BEST PRACTICE**

## Getting Started

### Prerequisites
- A Linux Distribution with bash support (tested with Ubuntu 20.04 on WSL)

- Docker and Docker Compose (maven build is performed using docker)

- Free network ports: 8080, 9080 for Tomcat; 6379 for Redis; 3000 for Nginx (load balancing for tomcat containers)

### Running the Application

First, clone this repository, and follow the next step to reproduce the issue.

#### To launch the configuration to reproduce the issue:

Run the script:
```sh
./launch-reproduce-issue.sh
```

#### To launch the working configuration:
Run the script:
```sh
./launch-working-config.sh
```

### Sending Test Requests

After setting up and running the desired configuration, you can send test requests to the server using:

```sh
./send-test-requests.sh
```

or

you can browse to http://localhost:3000/ login in using admin/admin123

If you're using the configuration to reproduce the issue, then the stack trace of the exception is found at the end of this README.

## POC Structure
```
.
├── Dockerfile-conf-working                # Dockerfile for the working setup
├── Dockerfile-reproduce-issue             # Dockerfile to reproduce the issue
├── README.md                              # This file
├── conf-reproduce-issue                   # Configuration files to reproduce the issue
│   ├── context.xml                        # Context configuration for Tomcat
│   ├── nginx.conf                         # Nginx configuration for the issue reproduction
│   └── redisson.conf                      # Redisson configuration for the issue reproduction
├── conf-working                           # Configuration files for the working setup
│   ├── context.xml                        # Context configuration for Tomcat
│   ├── nginx.conf                         # Nginx configuration for the working setup
│   └── redisson.conf                      # Redisson configuration for the working setup (using org.redisson.codec.SerializationCodec)
├── docker-compose-reproduce-issue.yml     # Docker Compose to set up the environment to reproduce the issue
├── docker-compose-working.yml             # Docker Compose to set up the working environment
├── launch-reproduce-issue.sh              # Script to launch the setup to reproduce the issue
├── launch-working-config.sh               # Script to launch the working setup
├── lib                                    # Libraries needed for the project
│   ├── redisson-all-3.25.2.jar            # Redisson library
│   └── redisson-tomcat-9-3.25.2.jar       # Redisson Tomcat library
├── pom.xml                                # Maven configuration file (mvn clean package to generate a war file)
├── send-test-requests.sh                  # Script to send test requests to the server
└── src                                    # Source code for the simple MVC application
```

## Expected Exception 
```
HTTP Status 500 – Internal Server Error
Type Exception Report

Message Unexpected exception while processing command

Description The server encountered an unexpected condition that prevented it from fulfilling the request.

Exception

org.redisson.client.RedisException: Unexpected exception while processing command
	org.redisson.command.CommandAsyncService.convertException(CommandAsyncService.java:300)
	org.redisson.command.CommandAsyncService.get(CommandAsyncService.java:117)
	org.redisson.RedissonObject.get(RedissonObject.java:90)
	org.redisson.RedissonMap.readAllMap(RedissonMap.java:889)
	org.redisson.tomcat.RedissonSession.getAttribute(RedissonSession.java:132)
	org.apache.catalina.session.StandardSessionFacade.getAttribute(StandardSessionFacade.java:101)
	org.springframework.security.web.context.HttpSessionSecurityContextRepository.readSecurityContextFromSession(HttpSessionSecurityContextRepository.java:160)
	org.springframework.security.web.context.HttpSessionSecurityContextRepository.loadContext(HttpSessionSecurityContextRepository.java:119)
	org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:98)
	org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:80)
	org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter.doFilterInternal(WebAsyncManagerIntegrationFilter.java:55)
	org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:117)
	org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:336)
	org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:211)
	org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:183)
	org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:354)
	org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:267)
Root Cause

com.esotericsoftware.kryo.KryoException: java.lang.UnsupportedOperationException
Serialization trace:
authorities (org.springframework.security.authentication.UsernamePasswordAuthenticationToken)
authentication (org.springframework.security.core.context.SecurityContextImpl)
	com.esotericsoftware.kryo.serializers.ReflectField.read(ReflectField.java:146)
	com.esotericsoftware.kryo.serializers.FieldSerializer.read(FieldSerializer.java:129)
	com.esotericsoftware.kryo.Kryo.readObject(Kryo.java:799)
	com.esotericsoftware.kryo.serializers.ReflectField.read(ReflectField.java:124)
	com.esotericsoftware.kryo.serializers.FieldSerializer.read(FieldSerializer.java:129)
	com.esotericsoftware.kryo.Kryo.readClassAndObject(Kryo.java:880)
	org.redisson.codec.Kryo5Codec$4.decode(Kryo5Codec.java:144)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:426)
	org.redisson.client.handler.CommandDecoder.decodeList(CommandDecoder.java:483)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:435)
	org.redisson.client.handler.CommandDecoder.decodeCommand(CommandDecoder.java:216)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:144)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:120)
	io.netty.handler.codec.ByteToMessageDecoder.decodeRemovalReentryProtection(ByteToMessageDecoder.java:529)
	io.netty.handler.codec.ReplayingDecoder.callDecode(ReplayingDecoder.java:366)
	io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:290)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:444)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
	io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
	io.netty.channel.DefaultChannelPipeline$HeadContext.channelRead(DefaultChannelPipeline.java:1410)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:440)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
	io.netty.channel.DefaultChannelPipeline.fireChannelRead(DefaultChannelPipeline.java:919)
	io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:166)
	io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:788)
	io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:724)
	io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:650)
	io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:562)
	io.netty.util.concurrent.SingleThreadEventExecutor$4.run(SingleThreadEventExecutor.java:997)
	io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
	io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30)
	java.base/java.lang.Thread.run(Thread.java:829)
Root Cause

java.lang.UnsupportedOperationException
	java.base/java.util.Collections$UnmodifiableCollection.add(Collections.java:1060)
	com.esotericsoftware.kryo.serializers.CollectionSerializer.read(CollectionSerializer.java:241)
	com.esotericsoftware.kryo.serializers.CollectionSerializer.read(CollectionSerializer.java:44)
	com.esotericsoftware.kryo.Kryo.readObject(Kryo.java:799)
	com.esotericsoftware.kryo.serializers.ReflectField.read(ReflectField.java:124)
	com.esotericsoftware.kryo.serializers.FieldSerializer.read(FieldSerializer.java:129)
	com.esotericsoftware.kryo.Kryo.readObject(Kryo.java:799)
	com.esotericsoftware.kryo.serializers.ReflectField.read(ReflectField.java:124)
	com.esotericsoftware.kryo.serializers.FieldSerializer.read(FieldSerializer.java:129)
	com.esotericsoftware.kryo.Kryo.readClassAndObject(Kryo.java:880)
	org.redisson.codec.Kryo5Codec$4.decode(Kryo5Codec.java:144)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:426)
	org.redisson.client.handler.CommandDecoder.decodeList(CommandDecoder.java:483)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:435)
	org.redisson.client.handler.CommandDecoder.decodeCommand(CommandDecoder.java:216)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:144)
	org.redisson.client.handler.CommandDecoder.decode(CommandDecoder.java:120)
	io.netty.handler.codec.ByteToMessageDecoder.decodeRemovalReentryProtection(ByteToMessageDecoder.java:529)
	io.netty.handler.codec.ReplayingDecoder.callDecode(ReplayingDecoder.java:366)
	io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:290)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:444)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
	io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:412)
	io.netty.channel.DefaultChannelPipeline$HeadContext.channelRead(DefaultChannelPipeline.java:1410)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:440)
	io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:420)
	io.netty.channel.DefaultChannelPipeline.fireChannelRead(DefaultChannelPipeline.java:919)
	io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:166)
	io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:788)
	io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:724)
	io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:650)
	io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:562)
	io.netty.util.concurrent.SingleThreadEventExecutor$4.run(SingleThreadEventExecutor.java:997)
	io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
	io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30)
	java.base/java.lang.Thread.run(Thread.java:829)
Note The full stack trace of the root cause is available in the server logs.

Apache Tomcat/9.0.84
```

