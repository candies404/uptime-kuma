# 前端构建阶段
FROM node:20-alpine as builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装项目依赖
RUN npm install --legacy-peer-deps && npm cache clean --force

# 复制前端代码
COPY . .

# 构建应用
RUN npm run build

# 清理不必要的文件和依赖
RUN npm prune --production

# 第二阶段：仅复制构建产物和运行时依赖
FROM node:20-alpine

# 设置工作目录
WORKDIR  /app

# 从构建器阶段复制构建产物和必要的运行时文件
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server ./server
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
# 确保 db 目录也被复制，包括 knex_init_db 模块
COPY --from=builder /app/db ./db

# 暴露 3001 端口
EXPOSE 3001

# 启动命令
CMD ["node", "server/server.js"]
