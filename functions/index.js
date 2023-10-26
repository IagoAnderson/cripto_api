const functions = require("firebase-functions");
const { Client } = require("@notionhq/client");

const notion = new Client({ auth: functions.config().notion.key });
const databaseId = functions.config().notion.database.id;

exports.enviarEmailParaNotion = functions.auth.user().onCreate(
    async (user) => {
        const userEmail = user.email;

        try {
            await notion.pages.create({
                parent: { database_id: databaseId },
                properties: {
                    Email: {
                        title: [{ type: "text", text: { content: userEmail } }],
                    },
                    Etapa: {
                        multi_select: [{ name: "Novo Cadastro" }],
                    },
                },
            });
            console.log('AUTH: Sincronização com Notion realizada com sucesso.');
        } catch (error) {
            console.error('AUTH: Erro na Sincronização com Notion.');
        }
        return true;
    }
);
