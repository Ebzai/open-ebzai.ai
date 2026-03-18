# 1. نستخدموا نسخة Node.js 22 المستقرة
FROM node:22

# 2. تنصيب الأدوات الأساسية (مهمة جداً للمكتبات والسكربتات)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# 3. تنصيب pnpm عالمياً
RUN npm install -g pnpm

# 4. تحديد مكان العمل داخل السيرفر
WORKDIR /app

# 5. نسخ كل ملفات المشروع (تأكد إنك مش ناسخ node_modules)
COPY . .

# 6. لقطة "الأمان": لو مجلد scripts موجود، صلح الملفات بتاع الويندوز وعطيهم صلاحية
RUN if [ -d "scripts" ]; then \
    find scripts -type f -name "*.sh" -exec dos2unix {} \; && \
    chmod -R +x scripts/; \
    else \
    echo "Scripts folder not found, skipping..."; \
    fi

# 7. تنصيب المكتبات (Dependencies)
RUN pnpm install --no-frozen-lockfile

# 8. بناء المشروع (Build)
RUN pnpm run build

# 9. إعدادات Hugging Face (المنفذ 7860)
EXPOSE 7860
ENV PORT=7860
ENV HOST=0.0.0.0

# 10. زر التشغيل النهائي
CMD ["pnpm", "start"]