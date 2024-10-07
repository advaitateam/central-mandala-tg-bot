import logging
import environ

env = environ.Env()

from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters, ContextTypes

# Настройка логирования
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

# Токен вашего бота
TOKEN = env.str('TOKEN')
# ID чата, куда будете пересылать сообщения
FORWARD_CHAT_ID = env.str('FORWARD_CHAT_ID')

# Обработчик команды /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    chat_id = update.message.chat.id
    await update.message.reply_text(f'Добро пожаловать! Ваш chat_id: {chat_id}')

# Обработчик команды /forward
async def forward(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    logging.info(f"Аргументы команды: {context.args}")
    if context.args:
        message = ' '.join(context.args)
        logging.info(f"Пересылаем сообщение: {message}")
        try:
            await context.bot.send_message(chat_id=FORWARD_CHAT_ID, text=message)
            if update.message.from_user:
                await update.message.from_user.send_message(f"Ваша заявка принята. Номер вашей заявки {message.id}")
        except Exception as e:
            logging.error(f"Ошибка при пересылке сообщения: {e}")
            await update.message.reply_text("Не удалось переслать сообщение.")
    else:
        await update.message.reply_text("Пожалуйста, введите сообщение для пересылки.")

# Функция для обработки любых текстовых сообщений
async def forward_to_group(update: Update, context):
    message = update.message  # Получаем сообщение пользователя
    # Пересылаем сообщение в группу
    if message:
        await message.forward(chat_id=FORWARD_CHAT_ID)

if __name__ == '__main__':
    # Создаем приложение и передаем токен бота
    app = ApplicationBuilder().token(TOKEN).build()

    # Обработчик команды /start
    start_handler = CommandHandler('start', start)
    app.add_handler(start_handler)

    # Обработчик команды /forward
    forward_handler = CommandHandler('forward', forward)
    app.add_handler(forward_handler)

    # Обработчик любых текстовых сообщений
    message_handler = MessageHandler(filters.TEXT & ~filters.COMMAND, forward_to_group)
    app.add_handler(message_handler)

    # Запуск бота
    app.run_polling()
